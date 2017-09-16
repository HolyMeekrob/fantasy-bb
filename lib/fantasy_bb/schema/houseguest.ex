defmodule FantasyBb.Schema.Houseguest do
	use Ecto.Schema
	import Ecto.Changeset, only: [
		cast: 3, validate_required: 2, unique_constraint: 3,  assoc_constraint: 2
	]

	schema "houseguest" do
		belongs_to :season, FantasyBb.Schema.Season
		belongs_to :player, FantasyBb.Schema.Player

		timestamps(updated_at: false)

		has_many :events, FantasyBb.Schema.Event
		has_many :draft_picks, FantasyBb.Schema.DraftPick
		many_to_many :trades, FantasyBb.Schema.Trade, join_through: "trade_piece"
	end

	def changeset(houseguest, params \\ %{}) do
		houseguest
		|> cast(params, [:season_id, :player_id])
		|> validate_required([:season_id, :player_id])
		|> unique_constraint(:player_id, name: :houseguest_season_id_player_id_index)
		|> assoc_constraint(:season)
		|> assoc_constraint(:player)
	end
end