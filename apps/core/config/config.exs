use Mix.Config

config :core,
  ecto_repos: [Core.Repo],
  namespace: Core

config :core, Core.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "$DB_NAME",
  username: "$DB_USER",
  password: "$DB_PASSWORD",
  hostname: "$DB_HOST",
  port: "$DB_PORT",
  pool_size: "$DB_POOL_SIZE",
  timeout: 15_000,
  pool_timeout: 15_000

# Configure crl api
config :core, Core.Api, sn_chunk_limit: 20_000

import_config "#{Mix.env()}.exs"
