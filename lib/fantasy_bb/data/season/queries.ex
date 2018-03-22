defmodule FantasyBb.Data.Season.Queries do
  alias FantasyBb.Repo
  alias FantasyBb.Data.Schema.Season

  import Ecto.Query, only: [from: 1, from: 2]

  def get(id) do
    get(Season, id)
  end

  def get(query, id) do
    Repo.get(query, id)
  end

  def get_all(query \\ Season) do
    Repo.all(query)
  end

  def query() do
    from(season in Season)
  end

  def with_players(query) do
    from(
      season in query,
      left_join: players in assoc(season, :players),
      preload: [players: players]
    )
  end

  def get_upcoming(query \\ Season) do
    today = Date.utc_today()

    from(
      season in query,
      where: season.start > ^today
    )
    |> Repo.all()
  end
end
