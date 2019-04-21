use Mix.Config

config :core,
  ecto_repos: [Core.Repo],
  namespace: Core,
  kafka: [
    partitions: {:system, :integer, "DS_KAFKA_PARTITIONS", 10}
  ]

config :core, Core.Repo,
  database: System.get_env("DB_NAME"),
  username: System.get_env("DB_USER"),
  password: System.get_env("DB_PASSWORD"),
  hostname: System.get_env("DB_HOST"),
  port: System.get_env("DB_PORT"),
  timeout: 15_000

# Configure crl api
config :core, Core.Api, sn_chunk_limit: {:system, :integer, "SERIAL_NUMBERS_CHUNK_LIMIT", 100}

config :logger_json, :backend,
  formatter: EhealthLogger.Formatter,
  metadata: :all

config :logger,
  backends: [LoggerJSON],
  level: :info

import_config "#{Mix.env()}.exs"
