defmodule FantasyBb.Core.Scoring.Season do
  alias FantasyBb.Data.Season

  defstruct hohs: [], otb: [], voters: [], evictees: []

  def create(%FantasyBb.Data.Schema.Season{} = season) do
    houseguests =
      season
      |> Season.get_houseguests()
      |> Enum.map(&Map.fetch!(&1, :id))

    %FantasyBb.Core.Scoring.Season{
      voters: houseguests
    }
  end
end
