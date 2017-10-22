defmodule FantasyBb.Repo.Migrations.AddScorable do
	use Ecto.Migration

	def change do
		create table(:scorable, primary_key: false) do
			add :id, :serial, primary_key: true
			add :name, :string, null: false
			add :description, :text
			add :default_point_value, :integer, null: false, default: 0

			timestamps()
		end

		create unique_index(:scorable, [:name])
	end
end
