defmodule FantasyBb.Season do
  alias FantasyBb.Repo
  alias FantasyBb.Schema.Season

  import Ecto.Query, only: [from: 1, from: 2]

  def create(season) do
    Season.changeset(season)
    |> Repo.insert()
  end

  def create!(season) do
    Season.changeset(season)
    |> Repo.insert!()
  end

  def query() do
    from(season in Season)
  end

  def with_players(query) do
    from(
      season in query,
      left_join: houseguests in assoc(season, :houseguests),
      join: player in assoc(houseguests, :player),
      preload: [houseguests: {houseguests, player: player}]
    )
  end
end
