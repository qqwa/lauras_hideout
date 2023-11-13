defmodule LaurasHideoutWeb.StashManagementLive do
  alias LaurasHideout.StashManagement
  use LaurasHideoutWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket, :account_stashes, StashManagement.get_stashes(socket.assigns.current_user.id))}
  end

  def handle_event("load_stashes", _params, socket) do
    account_stashes =
      StashManagement.request_account_stashes(socket.assigns.current_user, "Ancestor")

    {:noreply, assign(socket, :account_stashes, account_stashes)}
  end
end
