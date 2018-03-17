defmodule FantasyBb.Data.Player.Queries do
  alias FantasyBb.Repo
  alias FantasyBb.Data.Schema.Player

  import Ecto.Query, only: [from: 2]

  def get(id) do
    Repo.get(Player, id)
  end

  def get_all() do
    Repo.all(Player)
  end

  def get_all(ids) when is_list(ids) do
    from(
      player in Player,
      where: player.id in ^ids
    )
    |> Repo.all()
  end
end
