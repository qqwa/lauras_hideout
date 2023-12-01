defmodule LaurasHideout.Auth.UserSession do
  use LaurasHideout.Schema
  import Ecto.Changeset

  schema "user_sessions" do
    belongs_to :user, LaurasHideout.Auth.User
    timestamps()
  end

  def changeset(user_session, attrs) do
    user_session
    |> cast(attrs, [:user_id])
    |> validate_required([:user_id])
  end
end
