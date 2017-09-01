defmodule FantasyBb.Repo.Migrations.AddRuleset do
	use Ecto.Migration

	def change do
		create table(:ruleset, primary_key: false) do
			add :league_id, references(:league), primary_key: true
			add :event_type_id, references(:event_type, type: :serial), primary_key: true
			add :point_value, :integer, null: false

			timestamps()
		end
	end
end
