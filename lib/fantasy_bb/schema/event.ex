defmodule FantasyBb.Schema.Event do
	use Ecto.Schema
	import Ecto.Changeset, only: [
		cast: 3, validate_required: 2, assoc_constraint: 2
	]

	schema "event" do
		belongs_to :event_type, FantasyBb.Schema.EventType
		belongs_to :houseguest, FantasyBb.Schema.Houseguest
		belongs_to :week, FantasyBb.Schema.Week
		field :additional_info, :string

		timestamps()
	end

	def changeset(event, params \\ %{}) do
		event
		|> cast(params, [:event_type_id, :houseguest_id, :week_id, :additonal_info])
		|> validate_required([:event_type_id, :week_id])
		|> assoc_constraint(:event_type)
		|> assoc_constraint(:houseguest)
		|> assoc_constraint(:week)
	end
end