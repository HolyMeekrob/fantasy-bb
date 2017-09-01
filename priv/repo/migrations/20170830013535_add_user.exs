defmodule FantasyBb.Repo.Migrations.AddUser do
	use Ecto.Migration

	def change do
		create table(:user, primary_key: false) do
			add :email, :string, null: false, primary_key: true
			add :first_name, :string
			add :last_name, :string
			add :bio, :text
			add :favorite_player, :integer
			add :avatar, :string

			timestamps()
		end
	end
end
