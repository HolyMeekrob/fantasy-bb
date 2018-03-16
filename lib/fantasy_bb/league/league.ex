defmodule FantasyBb.League do
  alias FantasyBb.Repo
  alias FantasyBb.Data.Schema.League

  import Ecto.Query, only: [from: 1, from: 2]

  def create(league) do
    League.changeset(league)
    |> Repo.insert()
  end

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

  def get_all(query) do
    Repo.all(query)
  end
end
