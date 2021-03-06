defmodule FantasyBbWeb.Season.Authorization do
  import FantasyBb.Core.Account, only: [is_admin: 1]

  def authorize(action, user) when action in [:create, :update] do
    if is_admin(user) do
      :ok
    else
      {:error, :unauthorized}
    end
  end
end
