defmodule LaurasHideout.Auth.OAuthChallenge do
  use LaurasHideout.Schema
  import Ecto.Changeset

  @primary_key false
  schema "oauth_challenges" do
    field :state, :string, primary_key: true
    field :code_verifier, :string
    field :code_challenge, :string
    timestamps(updated_at: false)
  end

  def changeset(oauth_challenge, attrs) do
    oauth_challenge
    |> cast(attrs, [:state, :code_verifier, :code_challenge])
    |> validate_required([:state, :code_verifier, :code_challenge])
  end
end
