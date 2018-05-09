defmodule FantasyBb.Core.Scoring do
  alias FantasyBb.Core.Scoring.Event
  alias FantasyBb.Core.Scoring.EvictionCeremony
  alias FantasyBb.Core.Scoring.FinalCeremony
  alias FantasyBb.Core.Scoring.League
  alias FantasyBb.Core.Scoring.Rule
  alias FantasyBb.Core.Scoring.Trade

  def get_league_scores(%FantasyBb.Data.Schema.League{} = league) do
    initial_state = League.create(league)

    initial_state.events
    |> Enum.reduce(initial_state, &process/2)
    |> Map.fetch!(:teams)
    |> Enum.map(&Map.take(&1, [:id, :points]))
  end

  defp process(event, league) do
    updated_league = process_event(event, league)

    league.rules
    |> Enum.reduce({league, updated_league}, &Rule.process/2)
    |> elem(1)
    |> drop_event()
  end

  defp process_event(%Event{} = event, league) do
    Event.process(event, league)
  end

  defp process_event(%Trade{} = trade, league) do
    Trade.process(trade, league)
  end

  defp process_event(%EvictionCeremony{} = ceremony, league) do
    EvictionCeremony.process(ceremony, league)
  end

  defp process_event(%FinalCeremony{} = ceremony, league) do
    FinalCeremony.process(ceremony, league)
  end

  defp drop_event(%League{events: [_current | remaining]} = league) do
    %League{league | events: remaining}
  end
end
