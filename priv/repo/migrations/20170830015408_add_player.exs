defmodule FantasyBb.Repo.Migrations.AddPlayer do
	use Ecto.Migration

	def change do
		create table(:player, primary_key: false) do
			add :id, :serial, primary_key: true
			add :first_name, :string, null: false
			add :last_name, :string, null: false
			add :nick_name, :string

			timestamps()
		end

		alter table(:user) do
			modify :favorite_player, references(:player, type: :serial)
		end
	end
end
