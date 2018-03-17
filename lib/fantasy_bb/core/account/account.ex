defmodule FantasyBb.Core.Account do
  alias FantasyBb.Data.Account

  def is_admin(user) do
    true
  end

  def upsert_user(user) do
    Account.upsert_user(user)
  end

  def upsert_user!(user) do
    Account.upsert_user!(user)
  end
end
