use Mix.Config

# Configure your database
config :the_crawler, TheCrawler.Repo,
  username: "postgres",
  password: "postgres",
  database: "the_crawler_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :the_crawler, TheCrawlerWeb.Endpoint,
  http: [port: 4002],
  server: false

config :the_crawler, TheCrawlerWeb.JobLive, update_interval: 100
config :the_crawler, TheCrawlerWeb.ItemLive, update_interval: 100
# Print only warnings and errors during test
config :logger, level: :warn
