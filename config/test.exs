use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :weebus_price, WeebusPrice.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :weebus_price, WeebusPrice.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "weebus_price_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
