defmodule FantasyBb.Player do
  alias FantasyBb.Repo
  alias FantasyBb.Schema.Player
  alias FantasyBb.Player.Authorization

  defdelegate authorize(action, user), to: Authorization

  def create(player) do
    Player.changeset(player)
    |> Repo.insert()
  end

  def get(id) do
    Repo.get(Player, id)
  end

  def get!(id) do
    Repo.get!(Player, id)
  end

  def update(id, changes) do
    Player.changeset(get(id), changes)
    |> Repo.update()
  end
end
