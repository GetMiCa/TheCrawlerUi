# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :erlang_node_discovery,
  hosts: ["127.0.0.1", "crawlyui.com"],
  node_ports: [
    {:ui, 80}
  ]

ui_node = System.get_env("UI_NODE") || "ui@127.0.0.1"
ui_node = ui_node |> String.to_atom()


config :crawlers,
  immobiliare: [
    base_url: "https://www.immobiliare.it/vendita-case/milano",
    additional_parameters: "?criterio=rilevanza&prezzoMassimo=300000&tipoProprieta=1",
    bathroom_range: 1..4,
    floor_range: [1, 2, 3],
    room_range: 1..5,
    elevator: [true, false],
    basement: [true, false],
    balcony: [true, false],
    terrace: [true, false],
    state: ["Ristrutturato", "Da ristrutturare", "Buono"],
    zone_range: [
      "Centro",
      "Arco",
      "Genova",
      "Quadronno",
      "Garibaldi",
      "Fiera",
      "Navigli",
      "Romana",
      "Venezia",
      "Centrale",
      "Cenisio",
      "Certosa",
      "Inganni",
      "Famagosta",
      "Abbiategrasso",
      "Vittoria",
      "Cimiano",
      "Bicocca",
      "Solari",
      "Affori",
      "Sansiro",
      "Bisceglie",
      "Ripamonti",
      "Forlanini",
      "Studi",
      "Maggiolina",
      "Precotto",
      "Udine",
      "Pasteur",
      "Lambro",
      "Covervetto",
      "Napoli"
    ]
  ]


config :crawly,
  fetcher: {Crawly.Fetchers.Splash, [base_url: "http://scaper:8050/render.html", wait: 3]},
  concurrent_requests_per_domain: 16,
  retry: [
    retry_codes: [400, 500],
    max_retries: 3,
    ignored_middlewares: [Crawly.Middlewares.UniqueRequest]
  ],
  middlewares: [
    Crawly.Middlewares.UniqueRequest,
    {Crawly.Middlewares.UserAgent,
     user_agents: [
       "Mozilla/5.0 (Macintosh; Intel Mac OS X x.y; rv:42.0) Gecko/20100101 Firefox/42.0",
       "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, likeGecko) Chrome/51.0.2704.103 Safari/537.36",
       "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.106 Safari/537.36 OPR/38.0.2220.41"
     ]}
  ],
  pipelines: [
    {Crawly.Pipelines.Validate, fields: [:url, :title, :id, :price]},
    {Crawly.Pipelines.DuplicatesFilter, item_id: :id},
    {Crawly.Pipelines.Experimental.SendToUI, ui_node: ui_node},
    Crawly.Pipelines.JSONEncoder,
    {Crawly.Pipelines.WriteToFile, extension: "json", folder: "/tmp"}
  ]

# tell logger to load a LoggerFileBackend processes
config :logger,
  backends: [:console, {LoggerFileBackend, :debug_log}]

# configuration for the {LoggerFileBackend, :error_log} backend
config :logger, :debug_log,
  path: System.get_env("LOG_PATH", "/tmp/worker_debug.log"),
  level: :debug

