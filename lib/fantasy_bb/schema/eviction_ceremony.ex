defmodule FantasyBb.Schema.EvictionCeremony do
	use Ecto.Schema
	import Ecto.Changeset, only: [
		cast: 3, validate_required: 2, unique_constraint: 3, assoc_constraint: 2
	]

	schema "eviction_ceremony" do
		belongs_to :week, FantasyBb.Schema.Week
		field :order, :integer

		timestamps(updated_at: false)

		has_many :votes, FantasyBb.Schema.Vote
		has_many :events, FantasyBb.Schema.Event
	end

	def changeset(eviction_ceremony, params \\ %{}) do
		eviction_ceremony
		|> cast(params, [:week_id, :order])
		|> validate_required([:week_id, :order])
		|> unique_constraint(:week_id, name: :eviction_ceremony_week_id_order_index)
		|> assoc_constraint(:week)
	end
end