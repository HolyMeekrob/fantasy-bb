defmodule FantasyBb.Data.League.Commands do
  alias FantasyBb.Repo
  alias FantasyBb.Data.Schema.League

  def create(
        %{
          name: name,
          season_id: season_id,
          commissioner_id: commissioner_id
        } = league
      ) do
    League.changeset(%League{
      name: name,
      season_id: season_id,
      commissioner_id: commissioner_id
    })
    |> Repo.insert()
  end
end
