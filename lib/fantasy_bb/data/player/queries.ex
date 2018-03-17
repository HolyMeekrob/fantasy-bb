defmodule FantasyBb.Data.Player.Queries do
  alias FantasyBb.Repo
  alias FantasyBb.Data.Schema.Player

  import Ecto.Query, only: [from: 1, from: 2]

  def get(id) do
    Repo.get(Player, id)
  end

  def get_all(query \\ Player) do
    Repo.all(query)
  end

  def query() do
    from(player in Player)
  end

  def where_in(query, ids) do
    from(
      player in query,
      where: player.id in ^ids
    )
  end
end
