defmodule LaurasHideout.PoeApi.TypesTest do
  use ExUnit.Case, async: true
  alias LaurasHideout.PoeApi.Types
  alias LaurasHideout.PoeApi.Types.Stash

  test "List Stashes returns array of stashes" do
    body = %{
      "stashes" => [
        %{
          "id" => "607b7ac096",
          "index" => 0,
          "metadata" => %{"colour" => "cc009a"},
          "name" => "p1",
          "type" => "QuadStash"
        },
        %{
          "id" => "ad4994c787",
          "index" => 1,
          "metadata" => %{"colour" => "cc009a"},
          "name" => "pp",
          "type" => "QuadStash"
        }
      ]
    }

    stashes = Types.from_response(body)

    Enum.each(stashes, fn stash ->
      assert %Stash{} = stash
    end)
  end
end
