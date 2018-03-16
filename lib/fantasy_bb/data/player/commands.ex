defmodule FantasyBb.Data.Player.Commands do
  alias FantasyBb.Repo
  alias FantasyBb.Data.Schema.Player

  import FantasyBb.Data.Player.Queries, only: [get: 1]

  def create(player) do
    Player.changeset(player)
    |> Repo.insert()
  end

  def update(id, changes) do
    Player.changeset(get(id), changes)
    |> Repo.update()
  end
end
