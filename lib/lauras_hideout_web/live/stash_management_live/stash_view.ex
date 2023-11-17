defmodule LaurasHideoutWeb.StashManagementLive.StashView do
  alias LaurasHideout.StashManagement
  use LaurasHideoutWeb, :live_component

  def update(assigns, socket) do
    {:ok, socket |> assign(assigns) |> assign_stash()}
  end

  def assign_stash(socket) do
    stash = StashManagement.get_stash_snapshot(socket.assigns.stash_info["id"])
    assign_stash(socket, stash)
  end

  def assign_stash(socket, nil) do
    assign(socket, stash: nil)
  end

  def assign_stash(socket, stash) do
    items = convert_items(stash.items)
    stash = Map.put(stash, :items, items)
    assign(socket, stash: stash)
  end

  def convert_items(items) do
    Enum.map(items, fn item ->
      %{
        image: item["icon"],
        stack_size: Map.get(item, "stackSize", 1),
        name: "#{item["name"]} #{item["typeLine"]}"
      }
    end)
  end

  def handle_event("load_stash", _params, socket) do
    {:ok, stash} =
      StashManagement.refresh_account_stash(
        socket.assigns.current_user,
        socket.assigns.league,
        socket.assigns.stash_info["id"]
      )

    {:noreply, assign_stash(socket, stash)}
  end

  def render(assigns) do
    ~H"""
    <div>
      <button class="border-indigo-500 border-2 p-1 my-2" phx-click="load_stash" phx-target={@myself}>
        Refresh Stash
      </button>
      <h2 class="text-2xl font-bold">
        Stash: <%= @stash_info["name"] %>
      </h2>
      <%= if @stash do %>
        <p>
          Last Refresh: <%= @stash.last_refresh |> Calendar.strftime("%H:%M %d/%m/%Y ") %>
        </p>
        <div class="flex flex-wrap gap-4">
          <%= for item <- @stash.items do %>
            <div class="flex gap-2 items-center">
              <img class="block" src={item.image} />
              <div><%= "#{item.stack_size} - #{item.name}" %></div>
            </div>
          <% end %>
        </div>
      <% else %>
        <p>
          Last Refresh: No data yet. Refresh stash first.
        </p>
      <% end %>
    </div>
    """
  end
end
