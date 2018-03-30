defmodule FantasyBb.Core.Scoring.JuryVote do
  @enforce_keys [:voter_id, :candidate_id]
  defstruct [:voter_id, :candidate_id]

  def create(%FantasyBb.Data.Schema.JuryVote{} = vote) do
    %FantasyBb.Core.Scoring.JuryVote{
      voter_id: vote.voter_id,
      candidate_id: vote.candidate_id
    }
  end
end
