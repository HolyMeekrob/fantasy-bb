defmodule FantasyBb.Data.Utils do
  alias FantasyBb.Repo

  def get_association(obj, association) do
    obj
    |> Repo.preload(association)
    |> Map.fetch!(association)
  end
end
