defmodule TheCrawler.Repo do
  use Ecto.Repo,
    otp_app: :the_crawler,
    adapter: Ecto.Adapters.Postgres

  use Scrivener, page_size: 10
end
