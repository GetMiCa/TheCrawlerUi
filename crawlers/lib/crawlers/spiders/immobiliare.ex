defmodule Crawlers.Spiders.Immobiliare do
  use Crawly.Spider
  alias Crawlers.UrlsManagers

  @impl Crawly.Spider
  def base_url(), do: "https://www.immobiliare.it/"

  @impl Crawly.Spider
  def init() do
    [
      start_urls: UrlsManagers.Immobiliare.generate_urls()
    ]
  end

  @impl Crawly.Spider
  def parse_item(response) do
    {:ok, document} = Floki.parse_document(response.body)

    cond do
      response.request.url =~ "annunci" ->
        item = extract_item(document, response.request.url)
        %Crawly.ParsedItem{:items => [item], :requests => []}

      true ->
        requests =
          document
          |> extract_home_url()
          |> Enum.concat(extract_pagination(document, response.request.url))
          |> Enum.uniq()
          |> Enum.map(&Crawly.Utils.request_from_url/1)

        %Crawly.ParsedItem{:items => [], :requests => requests}
    end
  end

  defp extract_home_url(document),
    do:
      document
      |> Floki.find(".listing-item_body--content")
      |> Floki.find("a")
      |> Floki.attribute("href")

  defp extract_pagination(document, url) do
    cond do
      url =~ "&pag" ->
        []

      true ->
        document
        |> Floki.find(".pagination__number")
        |> Floki.find("ul")
        |> extract_last_page(url)
    end
  end

  defp extract_last_page([{"ul", _, children}], url),
    do: children |> Enum.take(-1) |> generate_urls(url)

  defp extract_last_page(_value, _url), do: []

  defp generate_urls([{"li", _, [{"a", _, [last]}]}], url) do
    case Integer.parse(last) do
      {converted, _} -> for page <- [2..converted], do: url <> "&pag=#{page}"
      _ -> []
    end
  end

  def extract_item(document, url) do
    title = document |> Floki.find(".im-titleBlock")
    details = document |> Floki.find(".im-mainFeatures")

    features =
      document
      |> Floki.find(".im-features__tagContainer")
      |> Floki.find("span")
      |> Enum.reduce([], fn x, acc -> [Floki.text(x) |> clean | acc] end)

    characteristic_names =
      document
      |> Floki.find(".im-features__title")
      |> Enum.reduce([], fn x, acc -> [Floki.text(x) |> clean | acc] end)

    characteristic_values =
      document
      |> Floki.find(".im-features__value")
      |> Enum.reduce([], fn x, acc -> [Floki.text(x) |> clean | acc] end)

    %{
      title: title |> Floki.find(".im-titleBlock__title") |> Floki.text(),
      id: url |> String.split("/") |> Enum.at(-1),
      municipality: title |> Floki.find(".im-location") |> Enum.at(0, "") |> Floki.text(),
      zone: title |> Floki.find(".im-location") |> Enum.at(1, "") |> Floki.text() |> clean,
      street: title |> Floki.find(".im-location") |> Enum.at(2, "") |> Floki.text() |> clean,
      url: url,
      price: details |> Floki.find(".im-mainFeatures__price") |> Floki.text() |> clean,
      rooms:
        details
        |> Floki.find("span")
        |> Floki.find(".im-mainFeatures__value")
        |> Enum.at(0, "")
        |> Floki.text()
        |> clean,
      surface:
        details
        |> Floki.find("span")
        |> Floki.find(".im-mainFeatures__value")
        |> Enum.at(1, "")
        |> Floki.text()
        |> clean,
      bathrooms:
        details
        |> Floki.find("span")
        |> Floki.find(".im-mainFeatures__value")
        |> Enum.at(2, "")
        |> Floki.text()
        |> clean,
      floor:
        details
        |> Floki.find("span")
        |> Floki.find(".im-mainFeatures__value")
        |> Enum.at(3, "")
        |> Floki.text()
        |> clean,
      features: features,
      basement: "cantina" in features,
      terrace: "terrazzo" in features,
      balcony: "balcone" in features,
      heating:
        characteristic_values
        |> Enum.at(
          characteristic_names
          |> Enum.find_index(fn x -> x == "riscaldamento" end)
          |> handle_response()
        ),
      state:
        characteristic_values
        |> Enum.at(
          characteristic_names
          |> Enum.find_index(fn x -> x == "stato" end)
          |> handle_response()
        ),
      built_year:
        characteristic_values
        |> Enum.at(
          characteristic_names
          |> Enum.find_index(fn x -> x == "anno di costruzione" end)
          |> handle_response()
        ),
      energy:
        characteristic_values
        |> Enum.at(
          characteristic_names
          |> Enum.find_index(fn x -> x == "efficienza energetica" end)
          |> handle_response()
        ),
      elevator:
        characteristic_values
        |> Enum.at(
          characteristic_names
          |> Enum.find_index(fn x -> x == "piano" end)
          |> handle_response()
        )
        |> String.contains?("con ascensore")
    }
  end

  defp handle_response(nil), do: 0
  defp handle_response(val), do: val

  defp clean(text),
    do:
      text
      |> String.trim()
      |> String.trim("\r\n")
      |> String.downcase()
end
