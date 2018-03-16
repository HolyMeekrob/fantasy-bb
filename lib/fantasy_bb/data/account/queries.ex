defmodule FantasyBb.Data.Account.Queries do
  alias FantasyBb.Repo
  alias FantasyBb.Data.Schema.User

  def get_user(id) do
    Repo.get(User, id)
  end

  def get_user_by_email(email) do
    Repo.get_by(User, email: email)
  end
end
