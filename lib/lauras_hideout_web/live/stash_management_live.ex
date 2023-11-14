defmodule LaurasHideoutWeb.StashManagementLive do
  alias LaurasHideout.StashManagement
  use LaurasHideoutWeb, :live_view

  def mount(_params, _session, socket) do
    socket = assign_selected_league(socket)

    stashes =
      StashManagement.get_stashes(socket.assigns.current_user.id, socket.assigns.selected_league)

    {:ok,
     socket
     |> assign_account_stashes(stashes)}
  end

  def handle_event("load_stashes", _params, socket) do
    if {:ok, stashes} =
         StashManagement.request_account_stashes(
           socket.assigns.current_user,
           socket.assigns.selected_league
         ) do
      {:noreply, assign_account_stashes(socket, stashes)}
    else
      {:noreply, put_flash(socket, :error, "Ops something went wrong")}
    end
  end

  defp assign_selected_league(socket) do
    assign(socket, :selected_league, "Ancestor")
  end

  defp assign_account_stashes(socket, stashes) do
    stashes =
      stashes
      |> put_colour_atom_into_stashes()

    assign(socket, :account_stashes, stashes)
  end

  defp put_colour_atom_into_stashes(stashes) do
    Enum.map(stashes, fn stash ->
      Map.put(stash, :color_class, "bg-" <> stash.metadata["colour"])
    end)
  end
end
