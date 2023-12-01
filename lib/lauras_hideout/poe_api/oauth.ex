defmodule LaurasHideout.PoeApi.OAuth do
  import LaurasHideout.PoeApi.Utils

  @base_url "https://www.pathofexile.com"
  @authorize_endpoint "/oauth/authorize"
  @access_token_endpoint "/oauth/token"

  def authorize_url(), do: @base_url <> @authorize_endpoint

  def base_url(), do: @base_url

  def get_access_token(%{code: code, code_verifier: code_verifier}) do
    form_map = access_token_form_map(code, code_verifier)

    client()
    |> Req.Request.merge_options(base_url: @base_url)
    |> Req.post(url: @access_token_endpoint, form: Map.to_list(form_map))
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
end
