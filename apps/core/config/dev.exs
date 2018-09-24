use Mix.Config

config :core, Core.Repo,
  adapter: Ecto.Adapters.Postgres,
  pool: Ecto.Adapters.SQL.Sandbox,
  database: "ds_dev",
  hostname: "ds_test_db"
