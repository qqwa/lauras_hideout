defmodule LaurasHideout.StashManagement.AccountStashInfo do
  use Ecto.Schema
  import Ecto.Changeset
  alias LaurasHideout.Accounts

  @primary_key false
  @foreign_key_type :binary_id
  schema "account_stash_infos" do
    belongs_to :user, Accounts.User
    field :league, :string
    field :stashes, {:array, :map}

    timestamps()
  end

  @doc false
  def changeset(account_stash, attrs) do
    account_stash
    |> cast(attrs, [:user_id, :league, :stashes])
    |> validate_required([:user_id, :league, :stashes])
  end
end
