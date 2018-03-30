defmodule FantasyBb.Data.Scorable do
  alias FantasyBb.Data.Schema.Scorable
  alias FantasyBb.Data.Scorable.Queries

  defdelegate get_all(query \\ Scorable), to: Queries
end