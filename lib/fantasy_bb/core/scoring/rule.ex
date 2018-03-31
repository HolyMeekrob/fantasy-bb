defmodule FantasyBb.Core.Scoring.Rule do
  @enforce_keys [:scorable_id, :point_value]
  defstruct [:scorable_id, :point_value]

  def create(%FantasyBb.Data.Schema.Rule{} = rule) do
    %FantasyBb.Core.Scoring.Rule{
      scorable_id: rule.scorable_id,
      point_value: rule.point_value
    }
  end
end
