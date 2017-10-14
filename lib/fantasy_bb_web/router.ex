defmodule FantasyBbWeb.Router do
  use FantasyBbWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/Houseguests", FantasyBbWeb do
    pipe_through :api

    get "/", HouseguestController, :index
    get "/:id", HouseguestController, :show
  end
end
