defmodule LaurasHideout.StashManagement.AccountStash do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  @foreign_key_type :binary_id
  schema "account_stashes" do
    field :folder_id, :string
    field :id, :string, primary_key: true
    field :index, :integer
    field :league, :string
    field :metadata, :map
    field :name, :string
    field :type, :string
    field :user_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(account_stash, attrs) do
    account_stash
    |> cast(attrs, [:league, :id, :index, :metadata, :name, :type, :user_id, :folder_id],
      empty_values: []
    )
    |> validate_required([:league, :id, :index, :metadata, :type, :user_id])
  end
end
