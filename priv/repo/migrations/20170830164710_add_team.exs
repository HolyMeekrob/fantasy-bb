defmodule FantasyBb.Repo.Migrations.AddTeam do
	use Ecto.Migration

	def change do
		create table(:team) do
			add :league_id, references(:league), null: false
			add :user_id, references(:user), null: false
			add :name, :string, null: false
			add :logo, :string

			timestamps()
		end

		create unique_index(:team, [:league_id, :user_id])
	end
end
