defmodule FantasyBb.Data.Team.Queries do
  alias FantasyBb.Repo
  alias FantasyBb.Data.Schema.Team

  import Ecto.Query, only: [from: 1, from: 2]

  def get(id) do
    get(Team, id)
  end

  def get(query, id) do
    Repo.get(query, id)
  end

  def query() do
    from(team in Team)
  end

  def for_overview(query) do
    from(
      team in query,
      inner_join: league in assoc(team, :league),
      inner_join: season in assoc(league, :season),
      inner_join: houseguests in assoc(season, :houseguests),
      inner_join: player in assoc(houseguests, :player),
      left_join: owner in assoc(team, :owner),
      preload: [
        owner: owner,
        league: {league, season: {season, houseguests: {houseguests, player: player}}}
      ]
    )
  end
end
