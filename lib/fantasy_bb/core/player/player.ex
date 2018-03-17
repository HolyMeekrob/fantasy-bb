defmodule FantasyBb.Core.Player do
  alias FantasyBb.Data.Player

  def create(player) do
    Player.create(player)
  end

  def get(ids) when is_list(ids) do
    Player.query()
    |> Player.where_in(ids)
    |> Player.get_all()
  end

  def get(id) do
    Player.get(id)
  end

  def get_all() do
    Player.get_all()
  end

  def update(id, changes) do
    Player.update(id, changes)
  end
end
