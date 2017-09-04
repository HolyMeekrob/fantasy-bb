defmodule FantasyBb.Schema.League do
	use Ecto.Schema

	schema "league" do
		field :name, :string
		belongs_to :season, FantasyBb.Schema.Season
		belongs_to :commissioner, FantasyBb.Schema.User

		timestamps()

		has_many :teams, FantasyBb.Schema.Team
		has_many :rulesets, FantasyBb.Schema.Ruleset
	end
end