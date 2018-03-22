defmodule FantasyBb.Data.DraftPick.Accessors do
  import FantasyBb.Data.Utils, only: [get_association: 2]

  def get_houseguest(draft_pick) do
    get_association(draft_pick, :houseguest)
  end
end
