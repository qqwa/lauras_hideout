defmodule LaurasHideout.Repo.Migrations.CreateAccountStashes do
  use Ecto.Migration

  def change do
    create table(:account_stashes, primary_key: false) do
      add :league, :string, null: false
      add :id, :string, primary_key: true, null: false
      add :index, :integer, null: false
      add :metadata, :map, null: false
      add :name, :string, null: false
      add :type, :string, null: false
      add :folder_id, :string
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id), null: false

      timestamps()
    end

    create index(:account_stashes, [:user_id])
  end
end
