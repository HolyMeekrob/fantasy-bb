defmodule FantasyBb.Core.League do
  alias FantasyBb.Core.League.LeagueState
  alias FantasyBb.Data.League

  def create(league) do
    League.create(league)
  end

  def get_leagues_for_user(user_id) do
    leagues =
      League.query()
      |> League.for_user(user_id)
      |> League.get_all()

    # TODO: Calculate scores
    Enum.map(leagues, &initial_state/1)
  end

  defp initial_state(league) do
    {League.get_season(league), LeagueState.init(league)}
  end
end
