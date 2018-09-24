use Mix.Config

config :core,
  ecto_repos: [Core.Repo],
  namespace: Core

config :core, Core.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "ds",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"

# Configure crl api
config :core, Core.Api, sn_chunk_limit: 20_000

import_config "#{Mix.env()}.exs"
