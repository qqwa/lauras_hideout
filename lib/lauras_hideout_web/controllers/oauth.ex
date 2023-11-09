defmodule LaurasHideoutWeb.OAuth do
  require Logger
  use LaurasHideoutWeb, :controller

  def init_oauth_authorization(conn, _params) do
    %{"_csrf_token" => csrf_token} = get_session(conn)

    case LaurasHideout.Accounts.authorization_request(csrf_token) do
      {:error, message} ->
        conn
        |> put_flash(:error, message)
        |> redirect(to: ~p"/")

      {:ok, uri} ->
        conn
        |> redirect(external: uri)
    end
  end

  def callback(conn, params) do
    %{"_csrf_token" => csrf_token} = get_session(conn)

    with true <- csrf_token == params["state"],
         {:ok, user} <- LaurasHideout.Accounts.access_token_request(params) do
      LaurasHideoutWeb.Auth.login(conn, user)
    else
      _ ->
        conn
        |> put_flash(:error, "Something went wrong try again later.")
        |> redirect(to: ~p"/")
    end
  end

  def logout(conn, _params) do
    LaurasHideoutWeb.Auth.logout(conn)
  end
end
