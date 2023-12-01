defmodule LaurasHideout.PoeApi.Log do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "poe_api_logs" do
    field :endpoint, :string
    field :message, :string
    field :status, :integer
    belongs_to :user, LaurasHideout.Auth.Schemas.User

    timestamps(updated_at: false)
  end

  @doc false
  def changeset(log, attrs) do
    log
    |> cast(attrs, [:status, :user_id, :endpoint, :message])
    |> validate_required([:status, :user_id, :endpoint])
  end
end
