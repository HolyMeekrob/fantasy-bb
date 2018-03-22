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
      where: teams.user_id == ^user_id,
      preload: [teams: teams]
    )
  end

  def get_all(query \\ League) do
    Repo.all(query)
  end
end
