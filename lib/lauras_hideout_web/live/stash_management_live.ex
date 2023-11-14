defmodule LaurasHideoutWeb.StashManagementLive do
  alias LaurasHideout.StashManagement
  use LaurasHideoutWeb, :live_view

  def mount(_params, _session, socket) do
    stashes = StashManagement.get_stashes(socket.assigns.current_user.id)
    {:ok, assign_account_stashes(socket, stashes)}
  end

  def handle_event("load_stashes", _params, socket) do
    if {:ok, stashes} =
         StashManagement.request_account_stashes(socket.assigns.current_user, "Ancestor") do
      {:noreply, assign_account_stashes(socket, stashes)}
    else
      {:noreply, put_flash(socket, :error, "Ops something went wrong")}
    end
  end

  defp assign_account_stashes(socket, stashes) do
    stashes =
      stashes
      |> put_colour_atom_into_stashes()

    assign(socket, :account_stashes, stashes)
  end

  defp put_colour_atom_into_stashes(stashes) do
    Enum.map(stashes, fn stash ->
      Map.put(stash, :colour, "bg-" <> stash.metadata["colour"])
    end)
  end
end
