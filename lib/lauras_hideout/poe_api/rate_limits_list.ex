defmodule LaurasHideout.PoeApi.RateLimitsList do
  use GenServer

  @moduledoc """
  GenServer that keeps tracks of reported rate-limits of the poe api.
  """

  def start_link(default) do
    GenServer.start_link(__MODULE__, default, name: __MODULE__)
  end

  def maybe_update_rate_limits(endpoint, rate_limits) do
    GenServer.cast(
      __MODULE__,
      {:maybe_update_rate_limits, %{endpoint: endpoint, rate_limits: rate_limits}}
    )
  end

  def get_rate_limits(endpoint) do
    GenServer.call(__MODULE__, {:get_rate_limits, endpoint})
  end

  # Callbacks
  @impl true
  def init(_) do
    {:ok, %{}}
  end

  @impl true
  def handle_call({:get_rate_limits, endpoint}, _from, state) do
    {:reply, Map.get(state, endpoint), state}
  end

  @impl true
  def handle_cast(
        {:maybe_update_rate_limits, %{endpoint: endpoint, rate_limits: rate_limits}},
        state
      ) do
    if rate_limits != state[endpoint] do
      new_state = Map.put(state, endpoint, rate_limits)
      {:noreply, new_state}
    else
      {:noreply, state}
    end
  end
end
