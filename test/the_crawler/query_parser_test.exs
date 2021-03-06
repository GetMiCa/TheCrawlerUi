defmodule TheCrawler.QueryParserTest do
  use ExUnit.Case

  test "parse simple key:value queries" do
    assert {:ok, ["title", "name"], "", %{}, {1, 0}, 10} ==
             TheCrawler.QueryParser.query("title:name")
  end

  test "parse queries with AND" do
    result = TheCrawler.QueryParser.query("title:name && title:chair")
    assert {:ok, ["title", "name ", "&&", " title", "chair"], "", %{}, {1, 0}, 25} == result
  end

  test "parse queries with OR" do
    result = TheCrawler.QueryParser.query("title:name || title:chair")
    assert {:ok, ["title", "name ", "||", " title", "chair"], "", %{}, {1, 0}, 25} == result
  end

  test "parse queries with OR and AND" do
    result = TheCrawler.QueryParser.query("title:name && price:6 || title:chair")

    assert {:ok, ["title", "name ", "&&", " price", "6 ", "||", " title", "chair"], "", %{},
            {1, 0}, 36} == result
  end

  test "can parse incomplete queries" do
    assert {:ok, [], "title", %{}, {1, 0}, 0} == TheCrawler.QueryParser.query("title")
    assert {:ok, [], "title::wow", %{}, {1, 0}, 0} == TheCrawler.QueryParser.query("title::wow")
    assert {:ok, [], "", %{}, {1, 0}, 0} == TheCrawler.QueryParser.query("")
    assert {:ok, [], "&& test:one", %{}, {1, 0}, 0} == TheCrawler.QueryParser.query("&& test:one")
  end
end
