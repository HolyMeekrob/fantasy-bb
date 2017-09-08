defmodule FantasyBb.Schema.Player do
	use Ecto.Schema
	import Ecto.Changeset, only: [cast: 3]

	schema "player" do
		field :first_name, :string
		field :last_name, :string
		field :nick_name, :string

		timestamps()

		has_many :users, FantasyBb.Schema.User, foreign_key: :favorite_player_id
		many_to_many :seasons, FantasyBb.Schema.Season, join_through: FantasyBb.Schema.Houseguest
	end

	def changeset(player, params \\ %{}) do
		player
		|> cast(params, [:first_name, :last_name, :nick_name])
	end
end