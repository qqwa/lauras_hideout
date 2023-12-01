defmodule LaurasHideoutWeb.User do
  use LaurasHideoutWeb, :controller

  def index(conn, _params) do
    render(assign_remaining_time(conn), :index)
  end

  def assign_remaining_time(conn) do
    remaining =
      if conn.assigns.current_user.oauth_token do
        expire = conn.assigns.current_user.oauth_token.expiration_date
        now = Timex.now()
        days = Timex.diff(expire, now, :days)

        if days < 3 do
          Timex.diff(expire, now, :hours)
          |> Timex.Duration.from_hours()
          |> Timex.format_duration(:humanized)
        else
          days
          |> Timex.Duration.from_days()
          |> Timex.format_duration(:humanized)
        end
      else
        nil
      end

    assign(conn, :remaining_time, remaining)
  end
end
