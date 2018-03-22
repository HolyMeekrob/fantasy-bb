defmodule FantasyBb.Data.League.Accessors do
  import FantasyBb.Data.Utils, only: [get_association: 2]

  def get_rules(league) do
    get_association(league, :rules)
  end

  def get_season(league) do
    get_association(league, :season)
  end
end
