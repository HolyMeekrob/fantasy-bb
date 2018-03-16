defmodule FantasyBb.Data.Player.Queries do
  alias FantasyBb.Repo
  alias FantasyBb.Schema.Player

  import Ecto.Query, only: [from: 2]

  def get() do
    Repo.all(Player)
  end

  def get(ids) when is_list(ids) do
    from(
      player in Player,
      where: player.id in ^ids
    )
    |> Repo.all()
  end

  def get(id) do
    Repo.get(Player, id)
  end
end
