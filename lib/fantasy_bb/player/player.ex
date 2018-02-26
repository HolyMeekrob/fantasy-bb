defmodule FantasyBb.Player do
  alias FantasyBb.Repo
  alias FantasyBb.Schema.Player
  alias FantasyBb.Player.Authorization

  defdelegate authorize(action, user), to: Authorization

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
