defmodule FantasyBb.Core.Scoring do
  alias FantasyBb.Core.Scoring.Event
  alias FantasyBb.Core.Scoring.EvictionCeremony
  alias FantasyBb.Core.Scoring.FinalCeremony
  alias FantasyBb.Core.Scoring.League
  alias FantasyBb.Core.Scoring.Rule
  alias FantasyBb.Core.Scoring.Trade

  def get_league_scores(%FantasyBb.Data.Schema.League{} = league) do
    initial_state = League.create(league)

    Enum.reduce(league.events, initial_state, &process/2)
  end

  defp process(event, league) do
    updated_league =
      event
      |> process_event(league)
      |> drop_event()

    league.rules
    |> Enum.reduce({league, updated_league}, &Rule.process/2)
    |> elem(1)
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

  defp process_event(%FinalCeremony{} = vote, league) do
    league
  end

  defp drop_event(%League{events: events} = league) do
    %League{league | events: Enum.drop(events, 1)}
  end
end
