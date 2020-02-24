defmodule AutotraderCoUK do
  @behaviour Crawly.Spider

  require Logger
  import Meeseeks.CSS

  @impl Crawly.Spider
  def base_url(), do: "https://www.autotrader.co.uk/"

  @impl Crawly.Spider
  def init() do
    [
      start_urls: [
        "https://www.autotrader.co.uk/cars/leasing/search",
        "https://www.autotrader.co.uk/cars/leasing/product/201911194514187"
      ]
    ]
  end

  @impl Crawly.Spider
  def parse_item(response) do
    case String.contains?(response.request_url, "cars/leasing/search") do
      false ->
        parse_product(response)
      true ->
        parse_search_results(response)
    end

  end

  defp parse_search_results(response) do
    # Parse page once only
    parsed_body = Meeseeks.parse(response.body, :html)

    # Extract href elements
    hrefs = parsed_body
            |> Meeseeks.all(css("ul.grid-results__list a"))
            |> Enum.map(fn a -> Meeseeks.attr(a, "href") end)
            |> Crawly.Utils.build_absolute_urls(base_url())

    # Get pagination
    pagination_hrefs = parsed_body
                       |> Meeseeks.all(css(".pagination a"))
                       |> Enum.map(
                            fn a ->
                              number = Meeseeks.own_text(a)
                              "/cars/leasing/search?pageNumber=" <> number
                            end)


    all_hrefs = hrefs ++ pagination_hrefs
    requests = Crawly.Utils.build_absolute_urls(all_hrefs, base_url())
               |> Crawly.Utils.requests_from_urls()

    %Crawly.ParsedItem{requests: requests, items: []}
  end

  defp parse_product(response) do
    # Parse page once only
    parsed_body = Meeseeks.parse(response.body, :html)

    title =
      parsed_body
      |> Meeseeks.one(css("h1.vehicle-title"))
      |> Meeseeks.own_text()

    price = parsed_body
            |> Meeseeks.one(css(".card-monthly-price__cost span"))
            |> Meeseeks.own_text()

    thumbnails =
      parsed_body
      |> Meeseeks.all(css("picture img"))
      |> Enum.map(fn elem -> Meeseeks.attr(elem, "src") end)

    url = response.request_url
    id = response.request_url
         |> URI.parse()
         |> Map.get(:path)
         |> String.split("/product/")
         |> List.last()

    item = %{
      id: id,
      url: url,
      thumbnails: thumbnails,
      price: price,
      title: title
    }

    %Crawly.ParsedItem{items: [item], requests: []}
  end
end
