defmodule FantasyBb.Repo.Migrations.AddUser do
	use Ecto.Migration

	def change do
		create table(:user) do
			add :email, :string, null: false
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
