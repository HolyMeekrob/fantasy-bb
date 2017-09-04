defmodule FantasyBb.Schema.Trade do
	use Ecto.Schema

	schema "trade" do
		belongs_to :initiated_by_team, FantasyBb.Schema.Team
		belongs_to :parent, FantasyBb.Schema.Trade
		field :message, :string
		field :is_approved, :boolean

		timestamps()

		has_one :child, FantasyBb.Schema.Trade, foreign_key: :parent_id
		many_to_many :houseguests, FantasyBb.Schema.Houseguest, join_through: "trade_piece"
	end
end