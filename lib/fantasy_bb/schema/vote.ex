defmodule FantasyBb.Schema.Vote do
	use Ecto.Schema
	import Ecto.Changeset, only: [
		cast: 3, validate_required: 2, unique_constraint: 3,
		assoc_constraint: 2, foreign_key_constraint: 2
	]

	schema "vote" do
		belongs_to :eviction_ceremony, FantasyBb.Schema.EvictionCeremony
		belongs_to :voter, FantasyBb.Schema.Houseguest
		belongs_to :candidate, FantasyBb.Schema.Houseguest

		timestamps(updated_at: false)
	end

	def changeset(vote, params \\ %{}) do
		vote
			|> cast(params, [:eviction_ceremony_id, :voter_id, :candidate_id])
			|> validate_required([:eviction_ceremony_id, :voter_id, :candidate_id])
			|> unique_constraint(:eviction_ceremony_id, name: :vote_eviction_ceremony_id_voter_id_index)
			|> assoc_constraint(:eviction_ceremony)
			|> foreign_key_constraint(:voter_id)
			|> foreign_key_constraint(:candidate_id)
	end
end