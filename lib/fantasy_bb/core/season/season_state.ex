defmodule FantasyBb.Core.Season.SeasonState do
  alias FantasyBb.Data.Season

  @enforce_keys [:id, :title]
  defstruct [:id, :title, active_houseguests: [], evicted_houseguests: []]

  def init(%FantasyBb.Data.Schema.Season{} = season) do
    houseguests =
      season
      |> Season.get_houseguests()
      |> Enum.map(&Map.fetch!(&1, :id))

    %FantasyBb.Core.Season.SeasonState{
      id: season.id,
      title: season.title,
      active_houseguests: houseguests
    }
  end
end
