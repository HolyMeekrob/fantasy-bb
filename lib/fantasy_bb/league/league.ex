defmodule FantasyBb.League do
  alias FantasyBb.Repo
  alias FantasyBb.Schema.League

  def create(league) do
    League.changeset(league)
    |> Repo.insert()
  end
end
