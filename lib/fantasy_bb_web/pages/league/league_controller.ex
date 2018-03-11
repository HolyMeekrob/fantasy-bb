defmodule FantasyBbWeb.LeagueController do
  use FantasyBbWeb, :controller

  alias FantasyBb.League

  def create_view(conn, _params) do
    render(conn, "create.html")
  end

  def create(conn, params) do
    with input = %FantasyBb.Schema.League{
           name: Map.get(params, "name")
         },
         {:ok, league} <- League.create(input) do
      conn
      |> put_status(:created)
      |> render("league.json", league)
    else
      {:error, _} ->
        send_resp(conn, :internal_server_error, "Error creating league")
    end
  end
end
