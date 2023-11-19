defmodule LaurasHideout.PoeApi.Types do
  @moduledoc """
  Converts json responses from the Developer API to more concrete types

  `def from_response` expects the json encoded body from any response and
  will deligate to the correct `def from_json` functions.
  """

  alias LaurasHideout.PoeApi.Types.Stash

  def from_response(%{"stashes" => stashes}) do
    Enum.map(stashes, fn stash ->
      Stash.from_json(stash)
    end)
  end

  def from_response(%{"stash" => stash}) do
    Stash.from_json(stash)
  end
end
