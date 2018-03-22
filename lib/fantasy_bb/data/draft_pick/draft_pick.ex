defmodule FantasyBb.Data.DraftPick do
  alias FantasyBb.Data.DraftPick.Accessors

  defdelegate get_houseguest(draft_pick), to: Accessors
end
