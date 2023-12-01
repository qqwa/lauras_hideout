defmodule LaurasHideout.Auth.User do
  use LaurasHideout.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: false}
  schema "users" do
    field :username, :string

    has_one :oauth_token, LaurasHideout.Auth.OAuthToken
    has_many :sessions, LaurasHideout.Auth.UserSession
    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :id])
    |> validate_required([:username, :id])
    |> unique_constraint(:id, name: :users_pkey)
  end
end
