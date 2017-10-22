defmodule FantasyBb.Schema.Scorable do
	use Ecto.Schema

	import Ecto.Changeset, only: [
		cast: 3, validate_required: 2, unique_constraint: 2
	]

	schema "scorable" do
		field :name, :string
		field :description, :string
		field :default_point_value, :integer

		timestamps()
	end

	def changeset(scorable, params \\ %{}) do
		scorable
			|> cast(params, [:name, :description, :default_point_value])
			|> validate_required([:name])
			|> unique_constraint(:name)
	end
end