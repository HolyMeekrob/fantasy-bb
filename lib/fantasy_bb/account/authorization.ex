defmodule FantasyBb.Account.Authorization do
  def is_admin(user) do
    true
  end

  def authorize(action, user, params) when action in [:update_user] do
    if user.email == params.email do
      :ok
    else
      {:error, :unauthorized}
    end
  end
end
