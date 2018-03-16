defmodule FantasyBbWeb.AccountController do
  use FantasyBbWeb, :controller

  alias FantasyBb.Account
  alias FantasyBb.Data.Account, as: Data
  import FantasyBbWeb.Account.Authorization, only: [authorize: 3]

  def profile(conn, _params) do
    render(conn, "profile.html")
  end

  def user(conn, _params) do
    render(conn, "user.json", conn.assigns.current_user)
  end

  def update_user(conn, params) do
    existing_user = conn.assigns.current_user
    updated_user = fix_keys(params)

    with :ok <- authorize(:update_user, existing_user, updated_user),
         input =
           existing_user
           |> Map.take([:first_name, :last_name, :email, :bio, :avatar])
           |> Map.merge(updated_user),
         {:ok, user} <- Data.upsert_user(input) do
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

  defp fix_keys(obj) do
    Enum.reduce(obj, Map.new(), &key_to_atom/2)
  end

  defp key_to_atom({key, val}, obj) do
    new_key =
      if is_binary(key) do
        String.to_atom(key)
      else
        key
      end

    Map.put(obj, new_key, val)
  end
end
