defmodule FantasyBb.Account do
  alias FantasyBb.Repo
  alias FantasyBb.Schema.User

  def upsert_user(user_attrs) do
    upsert_user(user_attrs, &Repo.insert_or_update/1)
  end

  def upsert_user!(user_attrs) do
    upsert_user(user_attrs, &Repo.insert_or_update!/1)
  end

  defp upsert_user(%{:email => email} = user_attrs, upsert_func) do
    case get_user_by_email(email) do
      nil -> %User{email: email}
      user -> user
    end
    |> User.changeset(user_attrs)
    |> upsert_func.()
  end

  defp upsert_user(_, _) do
    raise "Email is required to upsert a user."
  end

  def get_user(id) do
    Repo.get(User, id)
  end

  def get_user_by_email(email) do
    Repo.get_by(User, email: email)
  end
end
