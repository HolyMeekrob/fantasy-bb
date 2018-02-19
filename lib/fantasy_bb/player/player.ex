defmodule FantasyBb.Player do
  alias FantasyBb.Repo
  alias FantasyBb.Schema.Player

  import Ecto.Query, only: [from: 1, from: 2]

  def get(id) do
    Repo.get(Player, id)
  end

  def get!(id) do
    Repo.get!(Player, id)
  end
end
