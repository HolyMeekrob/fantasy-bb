defmodule FantasyBb.Data.Season.Commands do
  alias FantasyBb.Repo
  alias FantasyBb.Data.Schema.Season

  import FantasyBb.Data.Season.Queries, only: [query: 0, with_players: 1, get: 2]

  def create(season) do
    Season.changeset(Map.merge(%Season{}, season))
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
end
