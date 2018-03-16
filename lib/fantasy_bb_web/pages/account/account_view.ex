defmodule FantasyBbWeb.AccountView do
  use FantasyBbWeb, :view

  import FantasyBb.Core.Account, only: [is_admin: 1]

  def render("user.json", user) do
    %{
      firstName: user.first_name,
      lastName: user.last_name,
      email: user.email,
      bio: user.bio,
      avatar: user.avatar,
      isAdmin: is_admin(user)
    }
  end
end
