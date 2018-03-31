defmodule FantasyBb.Core.Scoring.Rule do
  alias FantasyBb.Core.Scoring.Scorable

  @enforce_keys [:scorable_id, :point_value]
  defstruct [:scorable_id, :point_value]

  def create(%FantasyBb.Data.Schema.Rule{} = rule) do
    %FantasyBb.Core.Scoring.Rule{
      scorable_id: rule.scorable_id,
      point_value: rule.point_value
    }
  end

  def process(%FantasyBb.Core.Scoring.Rule{} = rule, {prev, curr}) do
    Scorable.process(rule.scorable_id, rule.point_value, prev, curr)
  end
end
