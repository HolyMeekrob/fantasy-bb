defmodule FantasyBb.Core.Scoring.EvictionVote do
  @enforce_keys [:candidate_id]
  defstruct [:voter_id, :candidate_id]

  def create(%FantasyBb.Data.Schema.EvictionVote{} = vote) do
    %FantasyBb.Core.Scoring.EvictionVote{
      voter_id: vote.voter_id,
      candidate_id: vote.candidate_id
    }
  end
end
