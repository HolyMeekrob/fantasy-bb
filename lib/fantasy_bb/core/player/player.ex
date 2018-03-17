defmodule FantasyBb.Core.Player do
  alias FantasyBb.Data.Player

  def get_all(ids) do
    Player.get_all(ids)
  end
end
