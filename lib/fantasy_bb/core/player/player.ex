defmodule FantasyBb.Core.Player do
  alias FantasyBb.Data.Player

  def create(player) do
    Player.create(player)
  end

  def get(id) do
    Player.get(id)
  end

  def get_all() do
    Player.get_all()
  end

  def get_all(ids) do
    Player.get_all(ids)
  end

  def update(id, changes) do
    Player.update(id, changes)
  end
end
