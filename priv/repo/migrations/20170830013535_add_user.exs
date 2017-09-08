defmodule FantasyBb.Repo.Migrations.AddUser do
	use Ecto.Migration

	def change do
		execute "CREATE EXTENSION IF NOT EXISTS citext"
		create table(:user) do
			add :email, :citext, null: false
			add :first_name, :string
			add :last_name, :string
			add :bio, :text
			add :favorite_player_id, :integer
			add :avatar, :string

			timestamps()
		end

		create unique_index(:user, [:email])
	end
end
