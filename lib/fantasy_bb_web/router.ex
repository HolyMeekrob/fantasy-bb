defmodule FantasyBbWeb.Router do
	use FantasyBbWeb, :router

	pipeline :browser do
		plug :accepts, ["html"]
		plug :fetch_session
		plug :fetch_flash
		plug :protect_from_forgery
		plug :put_secure_browser_headers
	end
	
	pipeline :api do
		plug :accepts, ["json"]
	end

	scope "/", FantasyBbWeb do
		pipe_through :browser

		get "/", PageController, :index
	end
	
	scope "/Houseguests", FantasyBbWeb do
		pipe_through :api

		get "/", HouseguestController, :index
		get "/:id", HouseguestController, :show
	end
end
