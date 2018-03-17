defmodule FantasyBb.Data.Player do
  alias FantasyBb.Data.Player.Commands
  alias FantasyBb.Data.Player.Queries

  defdelegate get(id), to: Queries
  defdelegate get_all(), to: Queries
  defdelegate get_all(ids), to: Queries
  defdelegate create(player), to: Commands
  defdelegate update(id, player), to: Commands
end
