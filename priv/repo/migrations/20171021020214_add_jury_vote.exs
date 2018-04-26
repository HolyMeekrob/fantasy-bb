defmodule FantasyBb.Repo.Migrations.AddJuryVote do
  use Ecto.Migration

  def change do
    create table(:jury_vote, primary_key: false) do
      add(:id, :serial, primary_key: true)
      add(:season_id, references(:season, type: :serial), null: false)
      add(:voter_id, references(:houseguest, type: :serial))
      add(:candidate_id, references(:houseguest, type: :serial), null: false)

      timestamps(updated_at: false)
    end

    create(unique_index(:jury_vote, [:season_id, :voter_id]))
  end
end
