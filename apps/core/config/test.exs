use Mix.Config

# Databases configuration
config :core, Core.Repo,
  pool: Ecto.Adapters.SQL.Sandbox,
  database: "ds_test",
  port: 5432,
  timeout: 10_000,
  pool_timeout: 11_000,
  ownership_timeout: 60_000

config :kafka_ex, brokers: System.get_env("KAFKA_BROKERS")
