defmodule FantasyBbWeb.PageController do
	use FantasyBbWeb, :controller

	def index(conn, _params) do
		conn
		render conn, "index.html"
	end
end
