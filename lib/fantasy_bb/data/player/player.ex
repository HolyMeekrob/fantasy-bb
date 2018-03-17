defmodule FantasyBb.Data.Player do
  alias FantasyBb.Data.Player.Commands
  alias FantasyBb.Data.Player.Queries

  defdelegate get(), to: Queries
  defdelegate get(id), to: Queries
  defdelegate get_all(ids), to: Queries
  defdelegate create(season), to: Commands
  defdelegate update(id, season), to: Commands
end
