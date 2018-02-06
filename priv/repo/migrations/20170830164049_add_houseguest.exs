defmodule FantasyBb.Repo.Migrations.AddHouseguest do
  use Ecto.Migration

  def change do
    create table(:houseguest, primary_key: false) do
      add(:id, :serial, primary_key: true)
      add(:season_id, references(:season, type: :serial), null: false)
      add(:player_id, references(:player, type: :serial), null: false)
      add(:hometown, :string)

      timestamps(updated_at: false)
    end

    create(unique_index(:houseguest, [:season_id, :player_id]))
  end
end
