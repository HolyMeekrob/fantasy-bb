defmodule FantasyBb.Core.League do
  alias FantasyBb.Data.League

  def create(league) do
    League.create(league)
  end

  def get_leagues_for_user(user_id) do
    League.query()
    |> League.for_user(user_id)
    |> League.with_commissioner()
    |> League.with_teams()
    |> League.get_all()
  end
end
