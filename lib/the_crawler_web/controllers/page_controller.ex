defmodule TheCrawlerWeb.PageController do
  use TheCrawlerWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end