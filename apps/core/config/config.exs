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

config :kaffe,
  kafka_mod: :brod,
  producer: [
    endpoints: {:system, :string, "KAFKA_BROKERS"},
    topics: ["digital_signature"]
  ]

# Configure crl api
config :core, Core.Api, sn_chunk_limit: 20_000

config :logger_json, :backend,
  formatter: EhealthLogger.Formatter,
  metadata: :all

config :logger,
  backends: [LoggerJSON],
  level: :info

import_config "#{Mix.env()}.exs"
