defmodule TheCrawlerWeb.PageViewTest do
  use TheCrawlerWeb.ConnCase, async: true

  import Phoenix.View

  test "show index.html" do
    assert render_to_string(TheCrawlerWeb.PageView, "index.html", []) =~ "Web Crawling Dashboard."
  end
end
