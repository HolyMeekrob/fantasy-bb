defmodule FantasyBbWeb.Router do
  use FantasyBbWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", FantasyBbWeb do
    pipe_through :api
  end
end
