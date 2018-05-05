defmodule FantasyBb.Data.League.Queries do
  alias FantasyBb.Repo
  alias FantasyBb.Data.Schema.League

  import Ecto.Query, only: [from: 1, from: 2]

  def query() do
    from(league in League)
  end

  def for_user(query, user_id) do
    user_leagues_query =
      from(
        league in League,
        inner_join: teams in assoc(league, :teams),
        where: teams.user_id == ^user_id
      )

    from(
      league in query,
      inner_join: user_league in subquery(user_leagues_query),
      on: user_league.id == league.id,
      left_join: season in assoc(league, :season),
      left_join: teams in assoc(league, :teams),
      preload: [season: season, teams: teams]
    )
  end

  def get_all(query \\ League) do
    Repo.all(query)
  end
end
