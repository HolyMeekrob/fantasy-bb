defmodule FantasyBb.Data.Season.Queries do
  alias FantasyBb.Repo
  alias FantasyBb.Schema.Season

  import Ecto.Query, only: [from: 1, from: 2]

  def get(id) do
    get(Season, id)
  end

  def get(query, id) do
    Repo.get(query, id)
  end

  def query() do
    from(season in Season)
  end

  def with_players(query) do
    from(
      season in query,
      left_join: player in assoc(season, :players),
      preload: [players: player]
    )
  end

  def get_upcoming() do
    today = Date.utc_today()

    from(
      season in query(),
      where: season.start > ^today
    )
    |> Repo.all()
  end
end
