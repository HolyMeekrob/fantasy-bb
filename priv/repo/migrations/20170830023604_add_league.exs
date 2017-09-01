defmodule FantasyBb.Repo.Migrations.AddLeague do
	use Ecto.Migration

	def change do
		create table(:league) do
			add :name, :string, null: false
			add :season_id, references(:season, type: :serial), null: false
			add :commissioner, references(:user, column: :email, type: :string), null: false

			timestamps()
		end
	end
end
