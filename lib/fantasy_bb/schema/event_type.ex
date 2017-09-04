defmodule FantasyBb.Schema.EventType do
	use Ecto.Schema

	schema "event_type" do
		field :name, :string
		field :description, :string

		timestamps()

		has_many :rulesets, FantasyBb.Schema.Ruleset
		has_many :events, FantasyBb.Schema.Event
	end
end