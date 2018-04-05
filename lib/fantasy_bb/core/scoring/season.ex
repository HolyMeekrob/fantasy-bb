defmodule FantasyBb.Core.Scoring.Season do
  alias FantasyBb.Data.Season
  @enforce_keys [:id]
  defstruct [
    :id,
    hohs: MapSet.new(),
    otb: MapSet.new(),
    voters: MapSet.new(),
    evictees: MapSet.new()
  ]

  def create(%FantasyBb.Data.Schema.Season{} = season) do
    houseguests =
      season
      |> Season.get_houseguests()
      |> Enum.map(&Map.fetch!(&1, :id))

    %FantasyBb.Core.Scoring.Season{
      id: season.id,
      voters: houseguests
    }
  end
end
