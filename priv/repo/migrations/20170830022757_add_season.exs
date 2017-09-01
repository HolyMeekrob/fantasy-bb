defmodule FantasyBb.Repo.Migrations.AddSeason do
	use Ecto.Migration

	def change do
		create table(:season, primary_key: false) do
			add :id, :serial, primary_key: true
			add :start, :date, null: false
			add :subtitle, :string

			timestamps()
		end
	end
end
