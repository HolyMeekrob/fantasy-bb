defmodule FantasyBb.Repo.Migrations.AddVote do
	use Ecto.Migration

	def change do
		create table(:vote, primary_key: false) do
			add :id, :serial, primary_key: true
			add :eviction_ceremony_id, references(:eviction_ceremony, type: :serial), null: false
			add :voter_id, references(:houseguest, type: :serial), null: false
			add :candidate_id, references(:houseguest, type: :serial), null: false

			timestamps(updated_at: false)
		end
			create unique_index(:vote, [:eviction_ceremony_id, :voter_id])
	end
end
