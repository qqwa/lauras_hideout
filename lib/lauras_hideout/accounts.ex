defmodule LaurasHideout.Accounts do
  import Ecto.Query

  alias LaurasHideout.Accounts.Session
  alias LaurasHideout.Accounts.AccessToken
  alias LaurasHideout.Accounts.User
  alias LaurasHideout.PoeApi
  alias LaurasHideout.Repo
  alias LaurasHideout.Accounts.Challenge

  @moduledoc """
  Handels OAuth Flow
  """

  @doc """
  Generates the redirect url to start OAuth2 Flow

  Returns `{:ok, redirect_url}`
  """
  # https://datatracker.ietf.org/doc/html/rfc6749#section-4.1.1
  def authorization_request(state) do
    with {:ok, challenge} <- create_code_challenge(state) do
      {:ok, authorization_url(challenge)}
    end
  end

  @doc """
  Gets the access token.

  Uses the access token to create or get the user.
  Saves the access token for the user.
  """
  # https://datatracker.ietf.org/doc/html/rfc6749#section-4.1.3
  def access_token_request(params) do
    with {:ok, challenge} <- get_challenge(params["state"]),
         {:ok, response} <-
           PoeApi.OAuth.get_access_token(%{
             code: params["code"],
             code_verifier: challenge.code_verifier
           }),
         {:ok, access_token_map} <- handle_access_token_response(response),
         {:ok, user} <- get_or_create_user(access_token_map),
         {:ok, _} <- save_access_token(user, access_token_map) do
      {:ok, user}
    end
  end

  def get_challenge(state) do
    try do
      {:ok, Repo.get_by!(Challenge, state: state)}
    catch
      _ -> {:error, "Could not get challenge"}
    end
  end

  def handle_access_token_response(%{status: status, body: body}) do
    if status == 200 do
      {:ok, body}
    else
      {:error, "Access Token response returned status code: #{status}"}
    end
  end

  def save_access_token(user, token_map) do
    try do
      {:ok,
       %AccessToken{}
       |> AccessToken.changeset(%{user_id: user.id, token: token_map})
       |> Repo.insert!(
         on_conflict: [set: [token: token_map, inserted_at: DateTime.utc_now()]],
         conflict_target: :user_id
       )}
    catch
      _ -> {:error, "Could not save access token"}
    end
  end

  def create_session(user) do
    try do
      {:ok,
       %Session{}
       |> Session.changeset(%{user_id: user.id})
       |> Repo.insert!()}
    catch
      _ -> {:error, "Could not create session"}
    end
  end

  def get_user_with_access_token_by_session(session_id) do
    query =
      from s in Session,
        join: u in User,
        on: u.id == s.user_id,
        where: s.id == ^session_id,
        preload: :user

    session = Repo.one(query)
    Repo.preload(session.user, :access_token)
  end

  def get_session(session_id) do
    Repo.get(Session, session_id)
  end

  def delete_session(session) do
    Repo.delete(session)
  end

  def get_or_create_user(%{"username" => username} = map) do
    user = Repo.get_by(User, username: username)

    if user == nil do
      create_user(map)
    else
      {:ok, user}
    end
  end

  def create_user(params) do
    %User{}
    |> User.changeset(params)
    |> Repo.insert()
  end

  def get_code_challenge(state) do
    Repo.get_by(Challenge, state: state)
  end

  @doc """
  Creates a new code challenge for state. Replaces the old if one existed.
  """
  def create_code_challenge(state) do
    challenge_map =
      generate_code_challenge()
      |> Map.put(:state, state)

    time = DateTime.utc_now()

    try do
      {:ok,
       %Challenge{}
       |> Challenge.changeset(challenge_map)
       |> Repo.insert!(
         on_conflict: [
           set: [
             code_challenge: challenge_map.code_challenge,
             code_verifier: challenge_map.code_verifier,
             inserted_at: time,
             updated_at: time
           ]
         ],
         conflict_target: :state
       )}
    catch
      _ -> {:error, "Could not create challenge"}
    end
  end

  defp generate_code_challenge() do
    code_verifier = :crypto.strong_rand_bytes(32) |> Base.url_encode64()
    code_challenge = :crypto.hash(:sha256, code_verifier) |> Base.url_encode64()
    %{code_verifier: code_verifier, code_challenge: code_challenge}
  end

  # https://www.pathofexile.com/developer/docs/authorization#grants
  defp authorization_url(challenge) do
    PoeApi.OAuth.authorize_url() <> "?" <> authorization_url_query(challenge)
  end

  defp authorization_url_query(challenge) do
    %{}
    |> Map.put(:client_id, Application.get_env(:lauras_hideout, :client_id))
    |> Map.put(:response_type, "code")
    |> Map.put(:scope, PoeApi.OAuth.account_scopes())
    |> Map.put(:state, challenge.state)
    |> Map.put(:redirect_uri, Application.get_env(:lauras_hideout, :redirect_url))
    |> Map.put(:code_challenge, challenge.code_challenge)
    |> Map.put(:code_challenge_method, "S256")
    |> URI.encode_query()
  end
end
