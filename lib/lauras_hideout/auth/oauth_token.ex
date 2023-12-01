defmodule LaurasHideout.Auth.OAuthToken do
  require Logger
  use LaurasHideout.Schema
  import Ecto.Changeset

  schema "oauth_tokens" do
    belongs_to :user, LaurasHideout.Auth.User
    field :scope, :string
    field :expiration_date, :utc_datetime
    field :token_type, :string
    field :access_token, :string
    field :raw, :map
  end

  def changeset(oauth_token, attrs) do
    Logger.info(attrs, pretty: true)

    oauth_token
    |> cast(attrs, [:user_id, :scope, :expiration_date, :token_type, :access_token, :raw])
    |> validate_required([:user_id, :scope, :expiration_date, :token_type, :access_token, :raw])
  end
end
