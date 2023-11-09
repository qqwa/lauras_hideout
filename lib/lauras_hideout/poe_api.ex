defmodule LaurasHideout.PoeApi do
  def client(url) do
    Req.new(url: url, user_agent: user_agent())
  end

  def user_agent() do
    client_id = to_string(Application.get_env(:lauras_hideout, :client_id))
    version = LaurasHideout.Application.version()
    "OAuth #{client_id}/#{version} (contact: benjamin.baeumler@qqwa.de)"
  end
end
