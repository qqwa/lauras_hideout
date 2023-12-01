defmodule LaurasHideout.Auth.User do
  use LaurasHideout.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: false}
  schema "users" do
    field :username, :string
    field :is_admin, :boolean, default: false

    has_one :oauth_token, LaurasHideout.Auth.OAuthToken
    has_many :sessions, LaurasHideout.Auth.UserSession
    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :id, :is_admin])
    |> validate_required([:username, :id])
    |> unique_constraint(:id, name: :users_pkey)
  end
end
