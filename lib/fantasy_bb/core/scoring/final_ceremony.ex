defmodule FantasyBb.Core.Scoring.FinalCeremony do
  alias FantasyBb.Core.Scoring.JuryVote

  defstruct votes: []

  def create(votes) do
    %FantasyBb.Core.Scoring.FinalCeremony{
      votes: Enum.map(votes, &JuryVote.create/1)
    }
  end
end
