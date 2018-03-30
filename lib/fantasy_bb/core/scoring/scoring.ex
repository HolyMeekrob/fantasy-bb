defmodule FantasyBb.Core.Scoring do
  alias FantasyBb.Core.Scoring.Event
  alias FantasyBb.Core.Scoring.EvictionCeremony
  alias FantasyBb.Core.Scoring.JuryVote
  alias FantasyBb.Core.Scoring.League
  alias FantasyBb.Core.Scoring.Trade

  def get_league_scores(%FantasyBb.Data.Schema.League{} = league) do
    initial_state = League.create(league)

    Enum.reduce(league.events, initial_state, &process_event/2)
  end

  defp process_event(%Event{} = event, league) do
    Event.process(event, league)
  end

  defp process_event(%Trade{} = trade, league) do
    league
  end
  
  defp process_event(%EvictionCeremony{} = ceremony, league) do
    league
  end

  defp process_event(%JuryVote{} = vote, league) do
    league
  end
end
