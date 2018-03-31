defmodule FantasyBb.Core.Scoring.Scorable do
  def process(1, points, prev, curr) do
    {prev, curr}
  end

  def process(_, _, prev, curr) do
    {prev, curr}
  end
end
