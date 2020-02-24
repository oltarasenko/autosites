# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :crawly,
  fetcher: {Crawly.Fetchers.Splash, [base_url: "http://localhost:8050/render.html", wait: 3]},
  retry: [
    retry_codes: [400, 500],
    max_retries: 5,
    ignored_middlewares: [Crawly.Middlewares.UniqueRequest]
  ],
  closespider_timeout: 1,
  concurrent_requests_per_domain: 4,
  follow_redirects: true,
  closespider_itemcount: 1000,
  middlewares: [
    Crawly.Middlewares.DomainFilter,
    {Crawly.Middlewares.RequestOptions, [timeout: 30_000, recv_timeout: 15000]},
    Crawly.Middlewares.UniqueRequest,
    Crawly.Middlewares.UserAgent
  ],
  user_agents: [
    "Mozilla/5.0 (Macintosh; Intel Mac OS X x.y; rv:42.0) Gecko/20100101 Firefox/42.0",
    "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.103 Safari/537.36",
    "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.106 Safari/537.36 OPR/38.0.2220.41"
  ],
  pipelines: [
    {Crawly.Pipelines.Validate, fields: [:id, :title, :url, :price]},
    {Crawly.Pipelines.DuplicatesFilter, item_id: :id},
    {Crawly.Pipelines.JSONEncoder, []},
    {Crawly.Pipelines.WriteToFile, extension: "jl", folder: "/tmp"}
  ]
