defmodule FantasyBb.Schema.Ruleset do
	use Ecto.Schema

	@primary_key false
	schema "ruleset" do
		belongs_to :league, FantasyBb.Schema.League
		belongs_to :event_type, FantasyBb.Schema.EventType
		field :point_value, :integer

		timestamps()
	end
end