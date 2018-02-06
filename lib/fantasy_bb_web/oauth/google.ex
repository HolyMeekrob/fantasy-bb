defmodule FantasyBbWeb.OAuth.Google do
  @moduledoc """
  An OAuth 2 strategy for Google.
  """

  use OAuth2.Strategy

  defp config do
    [
      strategy: __MODULE__,
      authorize_url: "https://accounts.google.com/o/oauth2/v2/auth",
      token_url: "https://www.googleapis.com/oauth2/v4/token"
    ]
  end

  def client do
    Application.get_env(:fantasy_bb, __MODULE__)
    |> Keyword.merge(config())
    |> OAuth2.Client.new()
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
