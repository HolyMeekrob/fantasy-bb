defmodule FantasyBb.Player.Authorization do
  import FantasyBb.Account, only: [is_admin: 1]

  def authorize(action, user) when action in [:update] do
    if is_admin(user) do
      :ok
    else
      {:error, :unauthorized}
    end
  end
end
