defmodule FantasyBb.Core.Scoring.FinalCeremony do
  alias FantasyBb.Core.Scoring.JuryVote

  defstruct votes: []

  def create(votes) do
    %FantasyBb.Core.Scoring.FinalCeremony{
      votes: Enum.map(votes, &JuryVote.create/1)
    }
  end

  def process(_ceremony, league) do
    evictees =
      league.season.voters
      |> MapSet.union(league.season.hohs)
      |> MapSet.union(league.season.otb)
      |> MapSet.union(league.season.evictees)

    league = put_in(league.season.hohs, MapSet.new())
    league = put_in(league.season.otb, MapSet.new())
    league = put_in(league.season.voters, MapSet.new())
    put_in(league.season.evictees, evictees)
  end
end
