defmodule LaurasHideout.Repo.Migrations.Createchallenges do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true, null: false
      add :username, :string, null: false
      timestamps()
    end

    create table(:oauth_challenges, primary_key: false) do
      add :state, :string, primary_key: true
      add :code_verifier, :string, null: false
      add :code_challenge, :string, null: false

      timestamps(updated_at: false)
    end

    create table(:user_sessions) do
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id), null: false
      timestamps()
    end

    create table(:oauth_tokens) do
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id), null: false
      add :scope, :text, null: false
      add :expiration_date, :timestamptz, null: false
      add :token_type, :string, null: false
      add :access_token, :text, null: false

      add :raw, :map, null: false
    end

    create unique_index(:oauth_tokens, [:user_id])
  end
end
