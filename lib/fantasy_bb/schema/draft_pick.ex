defmodule FantasyBb.Schema.DraftPick do
	use Ecto.Schema

	schema "draft_pick" do
		belongs_to :team, FantasyBb.Schema.Team
		belongs_to :houseguest, FantasyBb.Schema.Houseguest
		field :draft_order, :integer

		timestamps()
	end
end