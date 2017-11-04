defmodule FantasyBbWeb.AuthController do
	use FantasyBbWeb, :controller

	alias FantasyBbWeb.OAuth.Google
	alias FantasyBb.Account

	@doc """
	Redirect to the OAuth2 provider based on the chosen strategy.

	Reached via /auth/:provider
	"""
	def index(conn, %{"provider" => provider}) do
		redirect(conn, external: authorize_url!(provider))
	end

	@doc """
	Log the user out.
	"""
	def delete(conn, _params) do
		conn
		|> put_flash(:info, "You have been logged out.")
		|> configure_session(drop: true)
		|> redirect(to: "/")
	end

	@doc """
	The callback that the OAuth provider will redirect the user back to with a
	code that can be used to request an access token. The access token will then
	be used to access protected resources on the user's behalf.

	Reached via /auth/:provider/callback
	"""
	def callback(conn, %{"provider" => provider, "code" => code}) do
		# Exchange an auth code for an access token
		client = get_token!(provider, code)

		# Requests the user's data with the access token
		user = get_user!(provider, client)

		# Store the user in the session under :current_user and redirect.
		conn
		|> put_session(:current_user, Account.upsert_user!(user))
		|> put_session(:access_token, client.token.access_token)
		|> redirect(to: "/")
	end

	defp authorize_url!("google") do
		scope = "https://www.googleapis.com/auth/userinfo.email"
		Google.authorize_url!(scope: scope)
	end

	defp authorize_url!(_) do
		raise "No matching provider available."
	end

	defp get_token!("google", code) do
		Google.get_token!(code: code)
	end

	defp get_token!(_, _) do
		raise "No matching provider available."
	end

	defp get_user!("google", client) do
		endpoint = "https://www.googleapis.com/plus/v1/people/me/openIdConnect"
		{:ok, %{body: user} = OAuth2.Client.get!(client, endpoint)}
		%{
			email: user["email"],
			first_name: user["given_name"],
			last_name: user["family_name"],
			avatar: user["picture"],
			external_id: user["sub"]
		}
	end
end