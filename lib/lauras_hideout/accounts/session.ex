defmodule LaurasHideout.Accounts.Session do
  alias LaurasHideout.Accounts
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "sessions" do
    belongs_to :user, Accounts.User

    timestamps()
  end

  @doc false
  def changeset(session, attrs) do
    session
    |> cast(attrs, [:user_id])
    |> validate_required([:user_id])
  end
end
