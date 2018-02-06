defmodule FantasyBb.Repo.Migrations.AddWeekTable do
  use Ecto.Migration

  def change do
    create table(:week, primary_key: false) do
      add(:id, :serial, primary_key: true)
      add(:season_id, references(:season, type: :serial), null: false)
      add(:week_number, :smallint, null: false)

      timestamps(updated_at: false)
    end

    create(unique_index(:week, [:season_id, :week_number]))
  end
end
