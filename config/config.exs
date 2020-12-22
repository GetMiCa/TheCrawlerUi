# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :the_crawler,
  ecto_repos: [TheCrawler.Repo]

config :the_crawler, TheCrawlerWeb.JobLive, update_interval: 20_000

# Configures the endpoint
config :the_crawler, TheCrawlerWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "NvJbkg8LD2bwbr4pT6v7UoaiqcaHIwIkCath+ECqQGN36U9CnCD5o3K8geVuKAmF",
  render_errors: [view: TheCrawlerWeb.ErrorView, accepts: ~w(html json)],
  pubsub_server: TheCrawler.PubSub,
  live_view: [signing_salt: "mKlOeOvv3fK8OTEEYjXqPaFqBXoVvRcC"]

config :logger,
  backends: [:console, {LoggerFileBackend, :debug_log}]

# configuration for the {LoggerFileBackend, :error_log} backend
config :logger, :debug_log,
  path: System.get_env("LOG_PATH", "./tmp/ui_debug.log"),
  level: :debug

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :the_crawler, TheCrawler.Scheduler,
  jobs: [
    # Every 5 mins
    {"*/5 * * * *", {TheCrawler.Manager, :update_job_status, []}},

    # Every 5 mins
    {"*/5 * * * *", {TheCrawler.Manager, :update_running_jobs, []}},

    # Every 5 mins
    {"*/5 * * * *", {TheCrawler.Manager, :update_jobs_speed, []}}
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
