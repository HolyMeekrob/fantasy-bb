defmodule FantasyBb.Data.Team.Accessors do
  import FantasyBb.Data.Utils, only: [get_association: 2]

  def get_draft_picks(team) do
    get_association(team, :draft_picks)
  end
end
