defmodule FantasyBb.Data.Trade.Queries do
  alias FantasyBb.Repo
  alias FantasyBb.Data.Schema.Trade

  import Ecto.Query, only: [from: 2]

  def for_scoring(season_id) do
    from(
      trade in Trade,
      inner_join: week in assoc(trade, :week),
      inner_join: houseguests in assoc(trade, :houseguests),
      where: week.season_id == ^season_id and trade.is_approved,
      preload: [week: week, houseguests: houseguests]
    )
    |> Repo.all()
  end
end
