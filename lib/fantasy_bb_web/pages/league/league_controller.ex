defmodule FantasyBbWeb.LeagueController do
  use FantasyBbWeb, :controller

  alias FantasyBb.League

  def create_view(conn, _params) do
    render(conn, "create.html")
  end

  def create(conn, params) do
    with input = %FantasyBb.Schema.League{
           name: Map.get(params, "name"),
           season_id: Map.get(params, "seasonId"),
           commissioner_id: Map.get(conn.assigns.current_user, :id)
         },
         {:ok, league} <- League.create(input) do
      send_resp(conn, :created, to_string(league.id))
    else
      {:error, _} ->
        send_resp(conn, :internal_server_error, "Error creating league")
    end
  end
end
