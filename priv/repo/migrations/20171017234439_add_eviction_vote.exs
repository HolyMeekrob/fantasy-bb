defmodule FantasyBb.Repo.Migrations.AddEvictionVote do
	use Ecto.Migration

	def change do
		create table(:eviction_vote, primary_key: false) do
			add :id, :serial, primary_key: true
			add :eviction_ceremony_id, references(:eviction_ceremony, type: :serial), null: false
			add :voter_id, references(:houseguest, type: :serial)
			add :candidate_id, references(:houseguest, type: :serial), null: false

			timestamps(updated_at: false)
		end
			create index(:eviction_vote, [:eviction_ceremony_id, :voter_id], unique: true, where: "voter_id IS NOT NULL")
	end
end
