defmodule FantasyBb.Schema.Team do
	use Ecto.Schema

	schema "team" do
		belongs_to :league, FantasyBb.Schema.League
		belongs_to :owner, FantasyBb.Schema.User, foreign_key: :user_id
		field :name, :string
		field :logo, :string

		timestamps()

		has_many :draft_picks, FantasyBb.Schema.DraftPick
		has_many :trades, FantasyBb.Schema.Trade, foreign_key: :initiated_by_team_id
	end
end