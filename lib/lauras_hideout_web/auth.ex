defmodule LaurasHideoutWeb.Auth do
  use LaurasHideoutWeb, :verified_routes
  import Plug.Conn
  import Phoenix.Controller

  require Logger
  alias LaurasHideout.Auth

  @max_age 60 * 60 * 24 * 30
  @remember_me_cookie "session_id"
  @remember_me_options [sign: true, max_age: @max_age, same_sit: "Lax"]

  @doc """
  Login user

  Clears session to avoid fixation attacks.
  Saves session_id in a cookie.
  """
  def login(conn, user) do
    conn =
      case Auth.create_user_session(user) do
        {:ok, session} ->
          conn
          |> renew_session()
          |> put_flash(:info, "Logged in as #{user.username}!")
          |> put_session(:session_id, session.id)
          |> put_resp_cookie(@remember_me_cookie, session.id, @remember_me_options)

        {:error, changeset} ->
          Logger.warning("Could not create user session for #{user} - #{changeset}")

          conn
          |> put_flash(:error, "Something went wrong try again later")
      end

    conn
    |> redirect(to: ~p"/")
  end

  @doc """
  Logout user by deleting session in the database and removing the session cookie.
  """
  def logout(conn) do
    session_id = get_session(conn, :session_id)
    session_id && Auth.delete_user_session(session_id)

    if conn.assigns.current_user do
      Auth.delete_access_token(conn.assigns.current_user.id)
    end

    conn
    |> renew_session()
    |> delete_resp_cookie(@remember_me_cookie)
    |> put_flash(:info, "Logged out!")
    |> redirect(to: ~p"/")
  end

  defp renew_session(conn) do
    conn
    |> configure_session(renew: true)
    |> clear_session()
  end

  @doc """
  Tries to get the current user by looking up the session.

  Sets `:current_user` to `nil` if no user/session can be found.
  """
  def fetch_current_user(conn, _opts) do
    {session_id, conn} = ensure_session(conn)
    user = session_id && Auth.get_user_with_access_token_by_user_session(session_id)
    assign(conn, :current_user, user)
  end

  defp ensure_session(conn) do
    if session_id = get_session(conn, :session_id) do
      {session_id, conn}
    else
      conn = fetch_cookies(conn, signed: [@remember_me_cookie])

      if session_id = conn.cookies[@remember_me_cookie] do
        conn = put_session(conn, :session_id, session_id)
        {session_id, conn}
      else
        {nil, conn}
      end
    end
  end

  @doc """
  Used for routes that require the user to be logged in.
  """
  def require_user(conn, _opts) do
    if conn.assigns.current_user do
      conn
    else
      conn
      |> put_flash(:error, "You need to login first.")
      |> redirect(to: ~p"/")
      |> halt()
    end
  end

  def require_admin(conn, _opts) do
    if conn.assigns.current_user.is_admin do
      conn
    else
      conn
      |> put_flash(:error, "Not permitted to access this page.")
      |> redirect(to: ~p"/")
      |> halt()
    end
  end

  def on_mount(:ensure_user, _params, session, socket) do
    socket = mount_current_user(socket, session)

    if socket.assigns.current_user do
      {:cont, socket}
    else
      socket =
        socket
        |> Phoenix.LiveView.put_flash(:error, "You must log in to access this page.")
        |> Phoenix.LiveView.redirect(to: ~p"/")

      {:halt, socket}
    end
  end

  def on_mount(:ensure_admin, _params, session, socket) do
    socket = mount_current_user(socket, session)

    if socket.assigns.current_user.is_admin do
      {:cont, socket}
    else
      socket =
        socket
        |> Phoenix.LiveView.put_flash(:error, "Not permitted to access this page.")
        |> Phoenix.LiveView.redirect(to: ~p"/")

      {:halt, socket}
    end
  end

  defp mount_current_user(socket, session) do
    Phoenix.Component.assign_new(socket, :current_user, fn ->
      if session_id = session["session_id"] do
        Auth.get_user_with_access_token_by_user_session(session_id)
      end
    end)
  end
end
