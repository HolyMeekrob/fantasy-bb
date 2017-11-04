defmodule FantasyBbWeb.Router do
	use FantasyBbWeb, :router

	pipeline :browser do
		plug :accepts, ["html"]
		plug :fetch_session
		plug :fetch_flash
		plug :protect_from_forgery
		plug :put_secure_browser_headers
		plug :assign_current_user
	end
	
	pipeline :api do
		plug :accepts, ["json"]
	end

	scope "/", FantasyBbWeb do
		pipe_through :browser

		get "/", PageController, :index
	end

	scope "/auth", FantasyBbWeb do
		pipe_through :browser

		get "/:provider", AuthController, :index
		get "/:provider/callback", AuthController, :callback
		delete "/logout", AuthController, :delete
	end
	
	scope "/Houseguests", FantasyBbWeb do
		pipe_through :api

		get "/", HouseguestController, :index
		get "/:id", HouseguestController, :show
	end

	# Fetch the current user from the session and add it to `conn.assigns`.
	defp assign_current_user(conn, _) do
		assign(conn, :current_user, get_session(conn, :current_user))
	end
end
