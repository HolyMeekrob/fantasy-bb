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

	pipeline :authenticated do
		plug :authenticate
	end

	scope "/", FantasyBbWeb do
		pipe_through :browser

		get "/", PageController, :index
	end

	scope "/login", FantasyBbWeb do
		pipe_through :browser

		get "/", LoginController, :index
	end

	scope "/auth", FantasyBbWeb do
		pipe_through :browser

		get "/:provider", AuthController, :index
		get "/:provider/callback", AuthController, :callback
		delete "/logout", AuthController, :delete
	end

	scope "/account", FantasyBbWeb do
		pipe_through([:browser, :authenticated])

		get "/profile", AccountController, :profile
	end
	
	scope "/houseguests", FantasyBbWeb do
		pipe_through :api

		get "/", HouseguestController, :index
		get "/:id", HouseguestController, :show
	end

	# Fetch the current user from the session and add it to `conn.assigns`.
	defp assign_current_user(conn, _) do
		assign(conn, :current_user, get_session(conn, :current_user))
	end

	# Check if the user is authenticated.
	# If not, redirect them to the login page.
	defp authenticate(conn, _params) do
		if(conn.assigns.current_user) do
			conn
		else
			conn
			|> put_flash(:error, "You must be logged in to access that page.")
			|> redirect(to: "/login")
			|> halt()
		end
	end
end
