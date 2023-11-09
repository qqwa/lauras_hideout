defmodule LaurasHideout.Repo.Migrations.CreateAccessTokens do
  use Ecto.Migration

  def change do
    create table(:access_tokens, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :token, :map, null: false
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id), null: false

      timestamps(updated_at: false)
    end

    create unique_index(:access_tokens, [:user_id])
  end
end
