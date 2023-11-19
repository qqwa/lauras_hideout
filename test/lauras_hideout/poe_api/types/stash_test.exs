defmodule LaurasHideout.PoeApi.Types.StashTest do
  use ExUnit.Case, async: true
  alias LaurasHideout.PoeApi.Types.Stash

  test "private stash without items" do
    body = %{
      "id" => "607b7ac096",
      "index" => 0,
      "metadata" => %{"colour" => "cc009a"},
      "name" => "p1",
      "type" => "QuadStash"
    }

    stash = Stash.from_json(body)

    assert stash.type == "QuadStash"
    assert stash.public? == false
    assert stash.items == nil
  end

  test "public stash without items" do
    body = %{
      "id" => "607b7ac096",
      "index" => 0,
      "metadata" => %{"colour" => "cc009a", "public" => true},
      "name" => "p1",
      "type" => "QuadStash"
    }

    stash = Stash.from_json(body)

    assert stash.type == "QuadStash"
    assert stash.public? == true
    assert stash.items == nil
  end
end
