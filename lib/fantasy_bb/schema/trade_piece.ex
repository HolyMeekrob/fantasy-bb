defmodule FantsyBb.Schema.TradePiece do
	use Ecto.Schema
	import Ecto.Changeset, only: [
		cast: 3, validate_required: 2, unique_constraint: 3, assoc_constraint: 2
	]

	schema "trade_piece" do
		belongs_to :trade, FantasyBb.Schema.Trade
		belongs_to :houseguest, FantasyBb.Schema.Houseguest
	end

	def changeset(trade_piece, params \\ %{}) do
		trade_piece
		|> cast(params, [:trade_id, :houseguest_id])
		|> validate_required([:trade_id, :houseguest_id])
		|> unique_constraint(:trade_id, name: :trade_piece_trade_id_houseguest_id_index)
		|> assoc_constraint(:trade)
		|> assoc_constraint(:houseguest)
	end
end