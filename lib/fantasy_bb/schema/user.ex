defmodule FantasyBb.Schema.User do
	use Ecto.Schema

	schema "user" do
		field :email, :string
		field :first_name, :string
		field :last_name, :string
		field :bio, :string
		field :avatar, :string
		belongs_to :favorite_player, FantasyBb.Schema.Player

		timestamps()

		has_many :commissioned_leagues, FantasyBb.Schema.League, foreign_key: :commissioner_id
		has_many :teams, FantasyBb.Schema.Team
	end
end