defmodule FantasyBbWeb.LeagueController do
  use FantasyBbWeb, :controller

  alias FantasyBb.Core.League

  def create_view(conn, _params) do
    render(conn, "create.html")
  end

  def create(conn, params) do
    with input = %{
           name: Map.get(params, "name"),
           season_id: Map.get(params, "seasonId"),
           commissioner_id: get_current_user_id(conn)
         },
         {:ok, league} <- League.create(input) do
      send_resp(conn, :created, to_string(league.id))
    else
      {:error, _} ->
        send_resp(conn, :internal_server_error, "Error creating league")
    end
  end

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def show(conn, %{"id" => _}) do
    render(conn, "show.html")
  end

  def get(conn, %{"id" => id}) do
    league = League.get_overview(id)
    scores = League.get_league_scores(league)
    merge = &Map.merge/2

    teams =
      (league.teams ++ scores)
      |> Enum.group_by(&Map.fetch!(&1, :id))
      |> Map.values()
      |> Enum.map(&Enum.reduce(&1, merge))

    is_commissioner = league.commissioner_id === get_current_user_id(conn)

    league =
      league
      |> Map.put(:is_commissioner, is_commissioner)
      |> Map.put(:teams, teams)

    render(conn, "league.json", league)
  end

  def by_user_id(conn, %{user_id: user_id}) do
    leagues =
      user_id
      |> League.get_leagues_for_user()
      |> Enum.map(&{&1, League.get_league_scores(&1)})

    render(conn, "user_leagues.json", %{leagues: leagues, user_id: user_id})
  end

  def for_current_user(conn, params) do
    user_id = get_current_user_id(conn)
    by_user_id(conn, Map.put(params, :user_id, user_id))
  end

  defp get_current_user_id(conn) do
    Map.get(conn.assigns.current_user, :id)
  end
end
