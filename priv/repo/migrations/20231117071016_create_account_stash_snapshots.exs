defmodule LaurasHideout.Repo.Migrations.CreateAccountStashSnapshots do
  use Ecto.Migration

  def change do
    create table(:account_stash_snapshots, primary_key: false) do
      add :stash_id, :string, primary_key: true
      add :league, :string
      add :items, {:array, :map}
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:account_stash_snapshots, [:user_id, :league])
  end
end
