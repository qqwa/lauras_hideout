defmodule LaurasHideoutWeb.StashManagementLive do
  require Logger
  alias LaurasHideout.StashManagement
  alias LaurasHideoutWeb.StashManagementLive
  use LaurasHideoutWeb, :live_view

  def mount(_params, _session, socket) do
    socket = assign_selected_league(socket)

    stashes =
      StashManagement.get_stash_infos(
        socket.assigns.current_user.id,
        socket.assigns.selected_league
      )

    {:ok,
     socket
     |> assign_account_stashes(stashes)
     |> assign(:stash, nil)}
  end

  def handle_params(%{"stash" => id}, _uri, socket) do
    stash =
      case Enum.filter(socket.assigns.account_stashes, fn stash ->
             stash["id"] == id
           end) do
        [] -> nil
        [stash] -> stash
      end

    {:noreply, assign(socket, :stash, stash)}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  def handle_event("load_stashes", _params, socket) do
    case StashManagement.refresh_account_stashes(
           socket.assigns.current_user,
           socket.assigns.selected_league
         ) do
      {:ok, stashes} ->
        {:noreply, assign_account_stashes(socket, stashes)}

      {:error, error} ->
        Logger.warning(error)
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
      Map.put(stash, :color_class, "bg-" <> stash["metadata"]["colour"])
    end)
  end
end
