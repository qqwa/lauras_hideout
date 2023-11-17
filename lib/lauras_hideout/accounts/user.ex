defmodule LaurasHideout.Accounts.User do
  alias LaurasHideout.Accounts
  alias LaurasHideout.StashManagement
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field :username, :string

    timestamps()
    has_one :access_token, Accounts.AccessToken
    has_many :session, Accounts.Session
    has_many :account_stash_info, StashManagement.AccountStashInfo
    has_many :account_stash_snapshot, StashManagement.AccountStashSnapshot
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username])
    |> validate_required([:username])
    |> unique_constraint(:username)
  end
end
