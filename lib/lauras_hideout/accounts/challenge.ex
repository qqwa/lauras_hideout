defmodule LaurasHideout.Accounts.Challenge do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "challenges" do
    field :code_challenge, :string
    field :code_verifier, :string
    field :state, :string, primary_key: true

    timestamps()
  end

  @doc false
  def changeset(challenge, attrs) do
    challenge
    |> cast(attrs, [:state, :code_verifier, :code_challenge])
    |> validate_required([:state, :code_verifier, :code_challenge])
    |> unique_constraint(:state)
  end
end
