defmodule LaurasHideout.Auth do
  import Ecto.Query
  alias LaurasHideout.Auth.UserSession
  alias LaurasHideout.Repo
  alias LaurasHideout.Auth.OAuth
  alias LaurasHideout.Auth.User
  alias LaurasHideout.Auth.OAuthToken
  alias LaurasHideout.PoeApi

  @doc """
  Generates a redirect url to https://www.pathofexile.com to request
  authentication from a user.

  Creates a challenge and writes it to the database for the given `state`.

  Returns `{:ok, redirect_uri}` or `{:error, reason}`.
  """
  def generate_authorization_redirect_uri(state) do
    with {:ok, challenge} <- OAuth.create_code_challenge(state) do
      {:ok, OAuth.authorization_url(challenge)}
    end
  end

  def maybe_authorize_code(%{"code" => code, "state" => code_state}, state) do
    with {:ok, challenge} <- OAuth.get_challenge(state, code_state),
         {:ok, response} <- OAuth.request_access_token(code, challenge.code_verifier),
         true <- PoeApi.Utils.is_good_response(response),
         {:ok, user} <- maybe_create_user(response.body),
         {:ok, _token} <- replace_access_token(response.body) do
      {:ok, user}
    end
  end

  @doc """
  Requires params `%{"id" => "...", "username" => "..."}`

  Expected to be called from the access_token response which comes in the form
  of:

  `%{"sub" => "...", "username" => "...", ...}`

  And will therefore remap "sub" to "id" if "sub" exists.
  """
  def maybe_create_user(params) do
    params = Map.put_new(params, "id", Map.get(params, "sub"))
    user = Repo.get(User, params["id"])

    if nil == user do
      %User{}
      |> User.changeset(params)
      |> Repo.insert()
    else
      {:ok, user}
    end
  end

  @doc """
  Insers a new access token into the database.

  If one existed for the same user it gets replaced.

  Returns `{:ok, %OAuthToken{}}` or `{:error, changeset}`.
  """
  def replace_access_token(params) do
    raw = params

    params =
      params
      |> Map.put_new("user_id", Map.get(params, "sub"))
      |> Map.put_new("raw", raw)
      |> Map.put_new(
        "expiration_date",
        Timex.shift(Timex.now(), seconds: Map.get(params, "expires_in"))
      )

    old_access_token = Repo.get(OAuthToken, params["user_id"])

    if old_access_token do
      # TODO: revoke old access token
    end

    %OAuthToken{}
    |> OAuthToken.changeset(params)
    |> Repo.insert(on_conflict: :replace_all, conflict_target: :user_id)
  end

  @doc """
  Returns a user with `username`. For debugging purposes.

  Returns `nil` if the user doesn't exist.
  """
  def get_user_by_username(username) do
    Repo.get_by(User, username: username)
  end

  @doc """
  Get user by user_session_id and preloads the oauth_token into the
  user struct.

  Returns `%User{}` or `nil`.
  """
  def get_user_with_access_token_by_user_session(user_session_id) do
    query =
      from u in User,
        join: s in assoc(u, :sessions),
        join: t in assoc(u, :oauth_token),
        where: s.id == ^user_session_id,
        preload: [:oauth_token]

    Repo.one(query)
  end

  @doc """
  Creates a new user session.

  Returns `{:ok, %UserSession{}}` or `{:error, changeset}`.
  """
  def create_user_session(%User{id: user_id}) do
    %UserSession{}
    |> UserSession.changeset(%{user_id: user_id})
    |> Repo.insert()
  end

  @doc """
  Get a user session.

  Returns `%UserSession{}` or `nil`.
  """
  def get_user_session(user_session_id) do
    Repo.get(UserSession, user_session_id)
  end

  @doc """
  Deletes a user session.

  Returns always `:ok`.
  """
  def delete_user_session(user_session_id) do
    Repo.delete_all(from UserSession, where: [id: ^user_session_id])
    :ok
  end
end
