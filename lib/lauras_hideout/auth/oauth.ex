defmodule LaurasHideout.Auth.OAuth do
  alias LaurasHideout.Auth.OAuthToken
  alias LaurasHideout.PoeApi
  alias LaurasHideout.Repo
  alias LaurasHideout.Auth.OAuthChallenge
  @base_url "https://www.pathofexile.com"
  @authorize_endpoint "/oauth/authorize"
  @access_token_endpoint "/oauth/token"
  @revoke_endpoint "/oauth/token/revoke"

  def revoke_access_token(%OAuthToken{} = oauth_token) do
    user = PoeApi.Utils.service_token()

    PoeApi.Utils.client_with_token(user.oauth_token.access_token)
    |> Req.Request.merge_options(base_url: @base_url, form: [token: oauth_token.access_token])
    |> Req.post(url: @revoke_endpoint)
    |> PoeApi.Utils.is_good_response()
  end

  def authorization_url(challenge) do
    "#{@base_url}#{@authorize_endpoint}?#{authorization_url_query(challenge)}"
  end

  def authorization_url_query(challenge) do
    %{}
    |> Map.put(:client_id, Application.get_env(:lauras_hideout, :client_id))
    |> Map.put(:response_type, "code")
    |> Map.put(:scope, account_scopes())
    |> Map.put(:state, challenge.state)
    |> Map.put(:redirect_uri, Application.get_env(:lauras_hideout, :redirect_url))
    |> Map.put(:code_challenge, challenge.code_challenge)
    |> Map.put(:code_challenge_method, "S256")
    |> URI.encode_query()
  end

  @doc """
  Creates a new code challenge for state. Replaces the old if one existed.
  """
  def create_code_challenge(state) do
    challenge_map =
      generate_code_challenge()
      |> Map.put(:state, state)

    try do
      {:ok,
       %OAuthChallenge{}
       |> OAuthChallenge.changeset(challenge_map)
       |> Repo.insert!(
         on_conflict: :replace_all,
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

  def request_access_token(code, code_verifier) do
    form_map = access_token_form_map(code, code_verifier)

    PoeApi.Utils.client()
    |> Req.post(base_url: @base_url, url: @access_token_endpoint, form: Map.to_list(form_map))
  end

  def account_scopes() do
    "account:profile account:characters account:stashes account:league_accounts account:item_filter"
  end

  defp access_token_form_map(code, code_verifier) do
    %{}
    |> Map.put(:client_id, Application.get_env(:lauras_hideout, :client_id))
    |> Map.put(:client_secret, Application.get_env(:lauras_hideout, :client_secret))
    |> Map.put(:grant_type, "authorization_code")
    |> Map.put(:code, code)
    |> Map.put(:redirect_uri, Application.get_env(:lauras_hideout, :redirect_url))
    |> Map.put(:scope, account_scopes())
    |> Map.put(:code_verifier, code_verifier)
  end

  def get_challenge(state, code_state) do
    with :ok <- validate_state(state, code_state) do
      challenge = Repo.get(OAuthChallenge, code_state)

      if challenge == nil do
        {:error, "Could not find challenge for #{code_state}"}
      else
        {:ok, challenge}
      end
    end
  end

  defp validate_state(state, code_state) do
    if code_state == state do
      :ok
    else
      {:error, "Expected state #{state} but got #{code_state}"}
    end
  end
end
