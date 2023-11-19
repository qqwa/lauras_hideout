defmodule LaurasHideout.PoeApi.Types.Item do
  defmodule Metadata do
    @moduledoc """
    Infos every item has or should have.
    """
    defstruct [:icon, :x, :y, :w, :h]
  end

  defmodule Currency do
    @moduledoc """
    Generic currency item.
    """
    defstruct [:name, :stack_size, :metadata]
  end

  defmodule DivinationCard do
    @moduledoc """
    Currently basically the same as `%Currency{}`, but in the future the
    result of turning a set in will be used too.
    """
    defstruct [:name, :stack_size, :metadata]
  end

  defmodule MapItem do
    @moduledoc """
    Maps are all Items that have a Map Tier.

    There are few special cases that make maps are more valuable:
      + 8mods or in generall high pack size and quanitity
      + mods like beyond, more magic/rare monsters
    And there are mods that make maps undesirable:
      + normal/magic and corrupted or mirrored
      + build breaking mods like reflect, no leech, less reg etc.
    """
    defstruct [:name, :map_tier, :metadata]
  end

  defmodule GenericItem do
    @moduledoc """
    For items that are not supported yet.
    """
    defstruct [:raw_item]
  end

  def from_json(nil), do: nil

  def from_json(%{"frameType" => 5, "baseType" => name, "stackSize" => stack_size} = json) do
    %Currency{
      name: name,
      stack_size: stack_size,
      metadata: get_metadata(json)
    }
  end

  def from_json(%{"frameType" => 6, "baseType" => name, "stackSize" => stack_size} = json) do
    %DivinationCard{
      name: name,
      stack_size: stack_size,
      metadata: get_metadata(json)
    }
  end

  def from_json(%{
        "baseType" => name,
        "properties" => [%{"name" => "Map Tier", "values" => [[map_tier, 0]]}]
      }) do
    %MapItem{
      name: name,
      map_tier: String.to_integer(map_tier)
    }
  end

  def from_json(item) do
    %GenericItem{
      raw_item: item
    }
  end

  defp get_metadata(json) do
    %Metadata{
      icon: Map.get(json, "icon"),
      x: Map.get(json, "x"),
      y: Map.get(json, "y"),
      w: Map.get(json, "w"),
      h: Map.get(json, "h")
    }
  end
end
