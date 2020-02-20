# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :night_game, NightGameWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "s2ERZjrH7R8dHL7awmy+tIr1MZIqe3bDGQpE5V5T+EE4LxdXSe+YZ99Ss3oFZnsQ",
  render_errors: [view: NightGameWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: NightGame.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [
    signing_salt: "asdlkfjasldkfjaksdjfhaksjdhfaksjdfhaksdjfhasdfkjh"
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import map
import_config "map.exs"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
