defmodule LaurasHideout.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      LaurasHideoutWeb.Telemetry,
      # Start the Ecto repository
      LaurasHideout.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: LaurasHideout.PubSub},
      # Start the Endpoint (http/https)
      LaurasHideoutWeb.Endpoint,
      # Start a worker by calling: LaurasHideout.Worker.start_link(arg)
      # {LaurasHideout.Worker, arg}
      LaurasHideout.PoeApi.RateLimitsList
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: LaurasHideout.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    LaurasHideoutWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  def version() do
    Application.spec(:lauras_hideout, :vsn) |> to_string()
  end
end
