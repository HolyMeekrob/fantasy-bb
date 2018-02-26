defmodule FantasyBb.Season.Authorization do
  import FantasyBb.Account, only: [is_admin: 1]

  def authorize(:create, user) do
    if is_admin(user) do
      :ok
    else
      {:error, :unauthorized}
    end
  end
end
