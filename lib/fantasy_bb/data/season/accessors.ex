defmodule FantasyBb.Data.Season.Accessors do
  import FantasyBb.Data.Utils, only: [get_association: 2]

  def get_houseguests(season) do
    get_association(season, :houseguests)
  end

  def get_jury_votes(season) do
    get_association(season, :jury_votes)
  end
end
