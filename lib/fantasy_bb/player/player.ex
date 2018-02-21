defmodule FantasyBb.Player do
  alias FantasyBb.Repo
  alias FantasyBb.Schema.Player

  def get(id) do
    Repo.get(Player, id)
  end

  def get!(id) do
    Repo.get!(Player, id)
  end
end
