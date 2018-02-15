defmodule FantasyBb.Season do
  alias FantasyBb.Repo
  alias FantasyBb.Schema.Season

  def create(season) do
    Season.changeset(season)
    |> Repo.insert()
  end

  def create!(season) do
    Season.changeset(season)
    |> Repo.insert!()
  end
end
