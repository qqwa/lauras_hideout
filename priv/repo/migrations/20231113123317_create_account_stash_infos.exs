defmodule LaurasHideout.Repo.Migrations.CreateAccountStashes do
  use Ecto.Migration

  def change do
    create table(:account_stash_infos, primary_key: false) do
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id), null: false
      add :league, :string, null: false
      add :stashes, {:array, :map}, null: false

      timestamps()
    end

    create unique_index(:account_stash_infos, [:user_id, :league])
  end
end
