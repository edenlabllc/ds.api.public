use Mix.Config

config :core,
  ecto_repos: [Core.Repo],
  namespace: Core,
  kafka: [
    partitions: {:system, :integer, "DS_KAFKA_PARTITIONS", 10}
  ]

config :core, Core.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: System.get_env("DB_NAME"),
  username: System.get_env("DB_USER"),
  password: System.get_env("DB_PASSWORD"),
  hostname: System.get_env("DB_HOST"),
  port: System.get_env("DB_PORT"),
  pool_size: System.get_env("DB_POOL_SIZE"),
  timeout: 15_000,
  pool_timeout: 15_000

config :kafka_ex,
  brokers: {:system, :string, "KAFKA_BROKERS"},
  disable_default_worker: false,
  sync_timeout: 3000,
  max_restarts: 10,
  max_seconds: 60,
  commit_interval: 5_000,
  auto_offset_reset: :earliest,
  commit_threshold: 100,
  kafka_version: "1.1.0"

# Configure crl api
config :core, Core.Api, sn_chunk_limit: 20_000

import_config "#{Mix.env()}.exs"
