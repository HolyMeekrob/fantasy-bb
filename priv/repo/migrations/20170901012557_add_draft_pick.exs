defmodule FantasyBb.Repo.Migrations.AddDraftPick do
	use Ecto.Migration

	def change do
		create table(:draft_pick) do
			add :team_id, references(:team), null: false
			add :houseguest_id, references(:houseguest, type: :serial)
			add :draft_order, :integer, null: false

			timestamps(updated_at: false)
		end
	end
end
