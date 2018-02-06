defmodule FantasyBbWeb.AccountController do
	use FantasyBbWeb, :controller

	def profile(conn, _params) do
		render conn, "profile.html"
	end

	def user(conn, _params) do
		render conn, "user.json", conn.assigns.current_user
	end

	def update_user(conn, params) do
		key_to_atom = fn({key, val}, obj) ->
			new_key =
				if is_binary(key) do
					String.to_atom(key)
				else
					key
				end
			Map.put(obj, new_key, val)
		end

		fix_keys = fn(obj) ->
			Enum.reduce(obj, Map.new, key_to_atom)
		end

		user = conn.assigns.current_user
		|> Map.take([:first_name, :last_name, :email, :bio, :avatar])
		|> Map.merge(fix_keys.(params))

		changeset = FantasyBb.Schema.User.changeset(
			%FantasyBb.Schema.User{id: conn.assigns.current_user.id}, user)
		
		case FantasyBb.Repo.update(changeset) do
			{:ok, updated_user } ->
				conn
				|> put_session(:current_user, updated_user)
				|> send_resp(:ok, "")
			
			{:error, _} ->
				send_resp(conn, :internal_server_error, "Error updating user profile")
			end
	end
end