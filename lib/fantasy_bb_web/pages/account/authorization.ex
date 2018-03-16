defmodule FantasyBbWeb.Account.Authorization do
  def authorize(action, user, params) when action in [:update_user] do
    if user.email == params.email do
      :ok
    else
      {:error, :unauthorized}
    end
  end
end
