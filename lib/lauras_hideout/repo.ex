defmodule LaurasHideout.Repo do
  use Ecto.Repo,
    otp_app: :lauras_hideout,
    adapter: Ecto.Adapters.Postgres
end
