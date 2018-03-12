defmodule FantasyBb.Season do
  alias FantasyBb.Repo
  alias FantasyBb.Schema.Season
  alias FantasyBb.Season.Authorization

  import Ecto.Query, only: [from: 1, from: 2]

  defdelegate authorize(action, user), to: Authorization

  def get(id) do
    get(Season, id)
  end

  defp get(query, id) do
    Repo.get(query, id)
  end

  def create(season) do
    Season.changeset(season)
    |> Repo.insert()
  end

  def update(id, changes) do
    season =
      query()
      |> with_players()
      |> get(id)

    Season.changeset(season, changes)
    |> Repo.update()
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
      where: season.start < ^today
    )
    |> Repo.all()
  end
end
