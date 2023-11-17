defmodule LaurasHideout.StashManagement.AccountStashSnapshot do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  @foreign_key_type :binary_id
  schema "account_stash_snapshots" do
    field :stash_id, :string, primary_key: true
    belongs_to :user, Accounts.User
    field :league, :string
    field :items, {:array, :map}

    timestamps()
  end

  @doc false
  def changeset(snapshot, attrs) do
    snapshot
    |> cast(attrs, [:stash_id, :user_id, :league, :items])
    |> validate_required([:stash_id, :user_id, :league, :items])
  end
end
