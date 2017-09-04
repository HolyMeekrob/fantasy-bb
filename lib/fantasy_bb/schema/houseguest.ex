defmodule FantasyBb.Schema.Houseguest do
	use Ecto.Schema

	schema "houseguest" do
		belongs_to :season, FantasyBb.Schema.Season
		belongs_to :player, FantasyBb.Schema.Player

		timestamps(updated_at: false)

		has_many :events, FantasyBb.Schema.Event
		has_many :draft_picks, FantasyBb.Schema.DraftPick
		many_to_many :trades, FantasyBb.Schema.Trade, join_through: "trade_piece"
	end
end