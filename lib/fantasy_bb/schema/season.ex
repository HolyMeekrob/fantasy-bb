defmodule FantasyBb.Schema.Season do
	use Ecto.Schema

	schema "season" do
		field :start, :date
		field :subtitle, :string

		timestamps()

		has_many :leagues, FantasyBb.Schema.League
		many_to_many :players, FantasyBb.Schema.Player, join_through: FantasyBb.Schema.Houseguest
	end
end