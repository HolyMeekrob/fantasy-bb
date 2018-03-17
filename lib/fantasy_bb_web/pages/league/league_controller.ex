defmodule FantasyBbWeb.LeagueController do
  use FantasyBbWeb, :controller

  alias FantasyBb.Core.League

  def create_view(conn, _params) do
    render(conn, "create.html")
  end

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def create(conn, params) do
    with input = %{
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

  def by_user_id(conn, %{user_id: user_id}) do
    leagues = League.get_leagues_for_user(user_id)

    render(conn, "user_leagues.json", %{leagues: leagues})
  end

  def for_current_user(conn, params) do
    user_id = Map.get(conn.assigns.current_user, :id)
    by_user_id(conn, Map.put(params, :user_id, user_id))
  end
end
