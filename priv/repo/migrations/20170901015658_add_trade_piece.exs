defmodule FantasyBb.Repo.Migrations.AddTradePiece do
	use Ecto.Migration

	def change do
		create table(:trade_piece, primary_key: false) do
			add :trade_id, references(:trade), primary_key: true
			add :houseguest_id, references(:houseguest, type: :serial), primary_key: true
		end
	end
end
