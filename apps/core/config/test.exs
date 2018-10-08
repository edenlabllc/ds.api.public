use Mix.Config

# Databases configuration
config :core, Core.Repo,
  pool: Ecto.Adapters.SQL.Sandbox,
  database: "ds_test",
  port: 5432,
  ownership_timeout: 15000
