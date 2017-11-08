defmodule FantasyBbWeb.AccountController do
	use FantasyBbWeb, :controller

	def profile(conn, _params) do
		render conn, "profile.html"
	end
end