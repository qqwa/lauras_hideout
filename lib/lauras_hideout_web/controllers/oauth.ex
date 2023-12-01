defmodule LaurasHideoutWeb.OAuth do
  require Logger
  use LaurasHideoutWeb, :controller

  def init_oauth_authorization(conn, _params) do
    %{"_csrf_token" => csrf_token} = get_session(conn)

    case LaurasHideout.Auth.generate_authorization_redirect_uri(csrf_token) do
      {:ok, redirect_uri} ->
        conn
        |> redirect(external: redirect_uri)

      {:error, message} ->
        conn
        |> put_flash(:error, message)
        |> redirect(to: ~p"/")
    end
  end

  def callback(conn, params) do
    %{"_csrf_token" => csrf_token} = get_session(conn)

    case LaurasHideout.Auth.maybe_authorize_code(params, csrf_token) do
      {:ok, user} ->
        LaurasHideoutWeb.Auth.login(conn, user)

      {:error, message} ->
        Logger.warning(message)

        conn
        |> put_flash(:error, "Something went wrong try again later.")
        |> redirect(to: ~p"/")
    end
  end

  def logout(conn, _params) do
    LaurasHideoutWeb.Auth.logout(conn)
  end
end
