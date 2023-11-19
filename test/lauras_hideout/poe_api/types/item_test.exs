defmodule LaurasHideout.PoeApi.Types.ItemTest do
  use ExUnit.Case, async: true
  alias LaurasHideout.PoeApi.Types.Item.{Currency, DivinationCard, MapItem, GenericItem}
  alias LaurasHideout.PoeApi.Types.Item

  test "Divine Orb is a Currency Item" do
    body = %{
      "baseType" => "Divine Orb",
      "descrText" =>
        "Right click this item then left click a magic, rare or unique item to apply it.",
      "explicitMods" => ["Randomises the values of the random modifiers on an item"],
      "frameType" => 5,
      "h" => 1,
      "icon" =>
        "https://web.poecdn.com/gen/image/WzI1LDE0LHsiZiI6IjJESXRlbXMvQ3VycmVuY3kvQ3VycmVuY3lNb2RWYWx1ZXMiLCJ3IjoxLCJoIjoxLCJzY2FsZSI6MX1d/e1a54ff97d/CurrencyModValues.png",
      "id" => "9b3cb50427c2ef702af8e43203fe0a9c40d1fc8bd5cc7831f92c7fef52baba70",
      "identified" => true,
      "ilvl" => 0,
      "inventoryId" => "Stash1",
      "league" => "Ancestor",
      "maxStackSize" => 10,
      "name" => "",
      "properties" => [
        %{"displayMode" => 0, "name" => "Stack Size", "type" => 32, "values" => [["2/10", 0]]}
      ],
      "stackSize" => 2,
      "typeLine" => "Divine Orb",
      "verified" => false,
      "w" => 1,
      "x" => 0,
      "y" => 1
    }

    item = Item.from_json(body)
    assert %Currency{} = item
  end

  test "Stand Map is Map" do
    body = %{
      "baseType" => "Strand Map",
      "descrText" =>
        "Travel to this Map by using it in a personal Map Device. Maps can only be used once.",
      "frameType" => 0,
      "h" => 1,
      "icon" =>
        "https://web.poecdn.com/gen/image/WzI4LDE0LHsiZiI6IjJESXRlbXMvTWFwcy9BdGxhczJNYXBzL05ldy9TdHJhbmQiLCJ3IjoxLCJoIjoxLCJzY2FsZSI6MSwibW4iOjE4LCJtdCI6MTZ9XQ/d679f1714d/Strand.png",
      "id" => "a244245a836b41baafcedef8685703f1e78ccbc3dc2e7c981af8665176f21647",
      "identified" => true,
      "ilvl" => 85,
      "inventoryId" => "Stash1",
      "league" => "Ancestor",
      "name" => "",
      "properties" => [
        %{"displayMode" => 0, "name" => "Map Tier", "type" => 1, "values" => [["16", 0]]}
      ],
      "typeLine" => "Strand Map",
      "verified" => false,
      "w" => 1,
      "x" => 1,
      "y" => 3
    }

    item = Item.from_json(body)
    assert %MapItem{} = item
    assert item.map_tier == 16
  end

  test "Akil's Prophecy is a DivinationCard" do
    body = %{
      "artFilename" => "AkilsProphecy",
      "baseType" => "Akil's Prophecy",
      "explicitMods" => [
        "<uniqueitem>{Elegant Round Shield}\r\n<corrupted>{Two-Implicit}\r\n<corrupted>{Corrupted}"
      ],
      "flavourText" => [
        "<size:28>{The hatungo know many answers to the same question, \r",
        "for time itself is a tangled web.}"
      ],
      "frameType" => 6,
      "h" => 1,
      "icon" =>
        "https://web.poecdn.com/gen/image/WzI1LDE0LHsiZiI6IjJESXRlbXMvRGl2aW5hdGlvbi9JbnZlbnRvcnlJY29uIiwidyI6MSwiaCI6MSwic2NhbGUiOjF9XQ/f34bf8cbb5/InventoryIcon.png",
      "id" => "6b40231b2cff5c7be13990e4fc560ab97447035740aecee8cbedb67b01cff749",
      "identified" => true,
      "ilvl" => 0,
      "inventoryId" => "Stash1",
      "league" => "Ancestor",
      "maxStackSize" => 3,
      "name" => "",
      "properties" => [
        %{"displayMode" => 0, "name" => "Stack Size", "type" => 32, "values" => [["3/3", 0]]}
      ],
      "stackSize" => 3,
      "typeLine" => "Akil's Prophecy",
      "verified" => false,
      "w" => 1,
      "x" => 0,
      "y" => 6
    }

    item = Item.from_json(body)
    assert %DivinationCard{} = item
    assert item.name == "Akil's Prophecy"
    assert item.stack_size == 3
  end

  test "Forbidden Tome is a GenericItem" do
    body = %{
      "baseType" => "Forbidden Tome",
      "descrText" => "Take this item to the Relic Altar in the Forbidden Sanctum to enter.",
      "flavourText" => [
        "Mundus noster cecidit. Daemones ubique sunt. Librum\r",
        "hunc in sacrarium conicio, ut forte alius viam inveniat..."
      ],
      "frameType" => 5,
      "h" => 1,
      "icon" =>
        "https://web.poecdn.com/gen/image/WzI1LDE0LHsiZiI6IjJESXRlbXMvQ3VycmVuY3kvU2FuY3R1bS9TYW5jdHVtS2V5IiwidyI6MSwiaCI6MSwic2NhbGUiOjF9XQ/d0326cac9a/SanctumKey.png",
      "id" => "881aceec44db613ac71e892c7f64728bbcce6ccfca94ae1ac3352ba9fbfa4f1c",
      "identified" => true,
      "ilvl" => 84,
      "inventoryId" => "Stash1",
      "league" => "Ancestor",
      "name" => "",
      "properties" => [
        %{"displayMode" => 0, "name" => "Area Level", "type" => 34, "values" => [["83", 0]]}
      ],
      "typeLine" => "Forbidden Tome",
      "verified" => false,
      "w" => 1,
      "x" => 0,
      "y" => 7
    }

    item = Item.from_json(body)
    assert %GenericItem{} = item
  end
end
