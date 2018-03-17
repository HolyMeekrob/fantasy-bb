defmodule FantasyBb.Data.Player do
  alias FantasyBb.Data.Player.Commands
  alias FantasyBb.Data.Player.Queries
  alias FantasyBb.Data.Schema.Player

  defdelegate get(id), to: Queries
  defdelegate get_all(query \\ Player), to: Queries
  defdelegate query(), to: Queries
  defdelegate where_in(query, ids), to: Queries
  defdelegate create(player), to: Commands
  defdelegate update(id, player), to: Commands
end
