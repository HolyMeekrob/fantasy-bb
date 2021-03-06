# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :fantasy_bb,
	ecto_repos: [FantasyBb.Repo]

# Configures the endpoint
config :fantasy_bb, FantasyBbWeb.Endpoint,
	url: [host: "localhost"],
	secret_key_base: "0toKs9icObF4SXWlRjK+nki9fQaaDsMTpvVdOuHh+/GVvAQGXPJE8ibxj9kBBw71",
	render_errors: [view: FantasyBbWeb.ErrorView, accepts: ~w(html json)],
	pubsub: [name: FantasyBb.PubSub,
					 adapter: Phoenix.PubSub.PG2]

# Configures Google OAuth
config :fantasy_bb, FantasyBbWeb.OAuth.Google,
	client_id: System.get_env("FBB_GOOGLE_CLIENT_ID"),
	client_secret: System.get_env("FBB_GOOGLE_CLIENT_SECRET"),
	redirect_uri: System.get_env("FBB_REDIRECT_URI")

# Configures Elixir's Logger
config :logger, :console,
	format: "$time $metadata[$level] $message\n",
	metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
