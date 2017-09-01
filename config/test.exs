use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :fantasy_bb, FantasyBbWeb.Endpoint,
	http: [port: 4001],
	server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :fantasy_bb, FantasyBb.Repo,
	adapter: Ecto.Adapters.Postgres,
	username: "postgres",
	password: "Z$c9tJqM!em3%VQZ5E5W",
	database: "fantasy_bb_test",
	hostname: "localhost",
	pool: Ecto.Adapters.SQL.Sandbox
