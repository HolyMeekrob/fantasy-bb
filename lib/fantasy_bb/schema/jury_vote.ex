defmodule FantasyBb.Schema.JuryVote do
	use Ecto.Schema

	import Ecto.Changeset, only: [
		cast: 3, validate_required: 2, unique_constraint: 3,
		assoc_constraint: 2, foreign_key_constraint: 2
	]

	schema "jury_vote" do
		belongs_to :season, FantasyBb.Schema.Season
		belongs_to :voter, FantasyBb.Schema.Houseguest
		belongs_to :candidate, FantasyBb.Schema.Houseguest

		timestamps(updated_at: false)
	end

	def changeset(jury_vote, params \\ %{}) do
		jury_vote
			|> cast(params, [:season_id, :voter_id, :candidate_id])
			|> validate_required([:season_id, :voter_id, :candidate_id])
			|> unique_constraint(:season_id, name: :jury_vote_season_id_voter_id_index)
			|> assoc_constraint(:season)
			|> foreign_key_constraint(:voter_id)
			|> foreign_key_constraint(:candidate_id)
	end
end