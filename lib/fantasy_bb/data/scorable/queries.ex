defmodule FantasyBb.Data.Scorable.Queries do
  alias FantasyBb.Repo
  alias FantasyBb.Data.Schema.Scorable

  def get_all(query \\ Scorable) do
    Repo.all(query)
  end
end
