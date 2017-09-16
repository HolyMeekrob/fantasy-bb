defmodule FantasyBb.Repo.Migrations.AddTradePiece do
	use Ecto.Migration

	def change do
		create table(:trade_piece) do
			add :trade_id, references(:trade), null: false
			add :houseguest_id, references(:houseguest, type: :serial), null: false
		end

		create unique_index(:trade_piece, [:trade_id, :houseguest_id])
	end
end
