defmodule FantasyBbWeb.HouseguestController do
	use FantasyBbWeb, :controller

	alias FantasyBb.Repo
	alias FantasyBb.Schema.Houseguest

	def index(conn, _params) do
		houseguests = Repo.all(Houseguest)
		render(conn, "index.json", houseguests: houseguests)
	end

	def show(conn, %{"id" => id}) do
		with houseguest = %Houseguest{} <- Repo.get(Houseguest, id) do
			render(conn, "show.json", houseguest: houseguest)
		else
			nil ->
				conn
				|> put_status(404)
				|> render(FantasyBbWeb.ErrorView, "404.json", error: "Not found")
		end
	end
end