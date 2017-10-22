defmodule FantasyBb.Repo.Migrations.AddEventType do
	use Ecto.Migration

	def change do
		create table(:event_type, primary_key: false) do
			add :id, :serial, primary_key: true
			add :name, :string, null: false

			timestamps()
		end

		create unique_index(:event_type, [:name])
	end
end
