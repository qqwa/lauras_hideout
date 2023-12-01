defmodule LaurasHideout.Repo.Migrations.CreatePoeApiLogs do
  use Ecto.Migration

  def change do
    create table(:poe_api_logs, primary_key: false) do
      add :status, :integer
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id), null: false
      add :endpoint, :string
      add :message, :string

      timestamps(updated_at: false)
    end
  end
end
