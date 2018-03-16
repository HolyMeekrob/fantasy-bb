defmodule FantasyBb.Data.Account do
  alias FantasyBb.Data.Account.Commands
  alias FantasyBb.Data.Account.Queries

  defdelegate get_user(id), to: Queries
  defdelegate upsert_user(input), to: Commands
  defdelegate upsert_user!(input), to: Commands
end
