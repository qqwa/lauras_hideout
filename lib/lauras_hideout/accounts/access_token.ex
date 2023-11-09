defmodule LaurasHideout.Accounts.AccessToken do
  alias LaurasHideout.Accounts
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "access_tokens" do
    field :token, :map
    belongs_to :user, Accounts.User

    timestamps(updated_at: false)
  end

  @doc false
  def changeset(access_token, attrs) do
    access_token
    |> cast(attrs, [:token, :user_id])
    |> validate_required([:token, :user_id])
    |> unique_constraint([:user_id])
  end
end
