defmodule FantasyBbWeb.HouseguestView do
	use FantasyBbWeb, :view

	def render("index.json", %{houseguests: houseguests}) do
		%{data: render_many(houseguests, __MODULE__, "houseguest.json")}
	end

	def render("show.json", %{houseguest: houseguest}) do
		%{data: render_one(houseguest, __MODULE__, "houseguest.json")}
	end

	def render("houseguest.json", %{houseguest: houseguest}) do
		%{
			id: houseguest.id,
			season_id: houseguest.season_id,
			player_id: houseguest.player_id,
			hometown: houseguest.hometown,
			inserted_at: houseguest.inserted_at
		}
	end
end