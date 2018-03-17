defmodule FantasyBb.Data.League.Queries do
  alias FantasyBb.Repo
  alias FantasyBb.Data.Schema.League

  import Ecto.Query, only: [from: 1, from: 2]

  def query() do
    from(league in League)
  end

  def for_user(query, user_id) do
    from(
      league in query,
      inner_join: teams in assoc(league, :teams),
      where: teams.user_id == ^user_id
    )
  end

  def with_teams(query) do
    from(
      league in query,
      left_join: teams in assoc(league, :teams),
      preload: [teams: teams]
    )
  end

  def with_commissioner(query) do
    from(
      league in query,
      inner_join: user in assoc(league, :commissioner),
      preload: [commissioner: user]
    )
  end

  def with_season(query) do
    from(
      league in query,
      inner_join: season in assoc(league, :season),
      preload: [season: season]
    )
  end

  def get_all(query \\ League) do
    Repo.all(query)
  end
end
