defmodule LaurasHideoutWeb.Router do
  use LaurasHideoutWeb, :router

  import LaurasHideoutWeb.Auth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {LaurasHideoutWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", LaurasHideoutWeb do
    pipe_through :browser

    get "/", PageController, :home
    get "/auth/poe", OAuth, :init_oauth_authorization
    get "/auth/callback/poe", OAuth, :callback
    delete "/logout", OAuth, :logout
  end

  scope "/", LaurasHideoutWeb do
    pipe_through [:browser, :require_user]

    get "/user", User, :index

    live_session :require_user,
      on_mount: [{LaurasHideoutWeb.Auth, :ensure_user}] do
      live "/stash", StashManagementLive
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", LaurasHideoutWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard in development
  if Application.compile_env(:lauras_hideout, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:browser, :require_admin]

      live_dashboard "/dashboard",
        metrics: LaurasHideoutWeb.Telemetry,
        on_mount: [{LaurasHideoutWeb.Auth, :ensure_admin}]
    end
  end
end
