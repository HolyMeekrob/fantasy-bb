defmodule FantasyBb.Data.League.Commands do
  alias FantasyBb.Repo
  alias FantasyBb.Data.Schema.League

  def create(league) do
    League.changeset(league)
    |> Repo.insert()
  end
end
