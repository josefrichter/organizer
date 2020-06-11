# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :organizer,
  ecto_repos: [Organizer.Repo]

# Configures the endpoint
config :organizer, OrganizerWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "vn++lxCLv4Aol7fqWEpwQmqSnqvCb/45Cf8JAmewfwFWbH3vxUM9x6qn4wAm93ZB",
  render_errors: [view: OrganizerWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Organizer.PubSub,
  live_view: [signing_salt: "Zs8MJ1sC"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

config :mailjex,
  api_base: "https://api.mailjet.com/v3",
  public_api_key: System.get_env("MAILJET_PUBLIC_API_KEY"), 
  private_api_key: System.get_env("MAILJET_PRIVATE_API_KEY"),
  development_mode: false