defmodule FantasyBb.Data.Team do
  alias FantasyBb.Data.Team.Accessors

  defdelegate get_draft_picks(team), to: Accessors
end
