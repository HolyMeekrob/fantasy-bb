defmodule FantasyBbWeb.OAuth.Google do
	@moduledoc """
	An OAuth 2 strategy for Google.
	"""

	use OAuth2.Strategy

	# TODO: Move environment variable retrieval to config.exs
	defp config do
		[
			strategy: __MODULE__,
			client_id: System.get_env("FBB_GOOGLE_CLIENT_ID"),
			client_secret: System.get_env("FBB_GOOGLE_CLIENT_SECRET"),
			redirect_uri: System.get_env("FBB_REDIRECT_URI"),
			site: "https://accounts.google.com",
			authorize_url: "https://accounts.google.com/o/oauth2/v2/auth",
			token_url: "https://www.googleapis.com/oauth2/v4/token"
		]
	end

	def client do
		OAuth2.Client.new(config())
	end

	def authorize_url!(params \\ []) do
		OAuth2.Client.authorize_url!(client(), params)
	end

	def get_token!(params \\ [], headers \\ [], opts \\ []) do
		OAuth2.Client.get_token!(client(), params, headers, opts)
	end

	def authorize_url(client, params) do
		OAuth2.Strategy.AuthCode.authorize_url(client, params)
	end

	def get_token(client, params, headers) do
		client
		|> put_param(:client_secret, client.client_secret)
		|> put_header("accept", "application/json")
		|> OAuth2.Strategy.AuthCode.get_token(params, headers)
	end
end