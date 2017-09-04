defmodule FantasyBb.Schema.Event do
	use Ecto.Schema

	schema "event" do
		belongs_to :event_type, FantasyBb.Schema.EventType
		belongs_to :houseguest, FantasyBb.Schema.Houseguest
		field :event_time, :naive_datetime
		field :additional_info, :string

		timestamps()
	end
end