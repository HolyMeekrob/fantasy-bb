defmodule FantasyBbWeb.AccountController do
  use FantasyBbWeb, :controller

  alias FantasyBb.Core.Account

  import FantasyBb.Core.Utils.Map, only: [string_keys_to_atoms: 1]
  import FantasyBbWeb.Account.Authorization, only: [authorize: 3]

  def profile(conn, _params) do
    render(conn, "profile.html")
  end

  def user(conn, _params) do
    render(conn, "user.json", conn.assigns.current_user)
  end

  def update_user(conn, params) do
    existing_user = conn.assigns.current_user
    updated_user = string_keys_to_atoms(params)

    with :ok <- authorize(:update_user, existing_user, updated_user),
         {:ok, user} <- Account.upsert_user(updated_user) do
      conn
      |> put_session(:current_user, user)
      |> render("user.json", user)
    else
      {:error, :unauthorized} ->
        send_resp(conn, :unauthorized, "Users can only update their own profiles")

      {:error, _} ->
        send_resp(conn, :internal_server_error, "Error updating user profile")
    end
  end
end
