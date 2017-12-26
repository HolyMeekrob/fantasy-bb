defmodule FantasyBbWeb.AccountController do
	use FantasyBbWeb, :controller

	def profile(conn, _params) do
		render conn, "profile.html"
	end

	def user(conn, _params) do
		json conn, %{firstName: "Test", lastName: "User"}
	end
end