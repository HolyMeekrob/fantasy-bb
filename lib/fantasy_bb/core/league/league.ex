defmodule FantasyBb.Core.League do
  alias FantasyBb.Data.League

  def create(league) do
    League.create(league)
  end

  # TODO: Calculate scores
  def get_leagues_for_user(user_id) do
    leagues =
      League.query()
      |> League.for_user(user_id)
      |> League.get_all()

    Enum.map(leagues, &{League.get_season(&1), &1})
  end
end
