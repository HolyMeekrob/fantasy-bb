defmodule FantasyBb.Schema.Season do
	use Ecto.Schema
	import Ecto.Changeset, only: [cast: 3]

	schema "season" do
		field :start, :date
		field :subtitle, :string

		timestamps()

		has_many :leagues, FantasyBb.Schema.League
		many_to_many :players, FantasyBb.Schema.Player, join_through: FantasyBb.Schema.Houseguest
	end

	def changeset(season, params \\ %{}) do
		season
		|> cast(params, [:start, :subtitle])
	end
end