# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :weebus_price,
  ecto_repos: [WeebusPrice.Repo]

# Configures the endpoint
config :weebus_price, WeebusPrice.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "gd9y/71xpVygtWOxntCsD4/gl9H2r2+rBtElcbaC2rFtAB+ksn/5XSGUDKEesgRi",
  render_errors: [view: WeebusPrice.ErrorView, accepts: ~w(html json)],
  pubsub: [name: WeebusPrice.PubSub,
           adapter: Phoenix.PubSub.PG2]

config :weebus_price,
  accounts: %{
    ignored_labels: [
      "Reimbursable",
      "Ignored"
    ],
    categories: [
      "Entertainment"
    ],
    people: %{
      mario: %{
        monthly_limit: 1000,
        accounts: [
          "Visa Signature",
          "Spend - everyday spending",
          "PayPal Account"
        ]
      }
    }
  }

config :hound, driver: "chrome_driver"

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
