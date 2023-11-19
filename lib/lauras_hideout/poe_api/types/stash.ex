defmodule LaurasHideout.PoeApi.Types.Stash do
  defstruct [:id, :index, :name, :type, :public?, :folder?, :color, :items]

  def from_json(json) do
    %__MODULE__{
      id: Map.get(json, "id"),
      index: Map.get(json, "index"),
      name: Map.get(json, "name"),
      type: Map.get(json, "type"),
      public?: Map.get(json["metadata"], "public", false),
      folder?: Map.get(json["metadata"], "folder", false),
      color: Map.get(json["metadata"], "colour"),
      items: nil
    }
  end
end
