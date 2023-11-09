defmodule LaurasHideout.Repo.Migrations.Createchallenges do
  use Ecto.Migration

  def change do
    create table(:challenges, primary_key: false) do
      add :state, :string, primary_key: true
      add :code_verifier, :string, null: false
      add :code_challenge, :string, null: false

      timestamps()
    end
  end
end
