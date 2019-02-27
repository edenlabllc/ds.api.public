use Mix.Config

# Databases configuration
config :core, Core.Repo,
  pool: Ecto.Adapters.SQL.Sandbox,
  database: "ds_test",
  port: 5432,
  timeout: 10_000,
  pool_timeout: 11_000,
  ownership_timeout: 60_000

config :kaffe,
  producer: [
    endpoints: System.get_env("KAFKA_BROKERS")
  ]

config :ex_unit, capture_log: true
config :logger, level: :warn
