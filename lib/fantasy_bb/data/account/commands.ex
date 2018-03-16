defmodule FantasyBb.Data.Account.Commands do
  alias FantasyBb.Repo
  alias FantasyBb.Data.Schema.User

  import FantasyBb.Data.Account.Queries, only: [get_user_by_email: 1]

  def upsert_user(input) do
    upsert_user(input, &Repo.insert_or_update/1)
  end

  def upsert_user!(input) do
    upsert_user(input, &Repo.insert_or_update!/1)
  end

  defp upsert_user(%{email: email} = input, upsert_func) do
    case get_user_by_email(email) do
      nil -> %User{email: email}
      user -> user
    end
    |> User.changeset(input)
    |> upsert_func.()
  end

  defp upsert_user(_, _) do
    raise "Email is required to upsert a user."
  end
end
