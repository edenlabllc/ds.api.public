use Mix.Config

# Configures Database
config :core, Core.Repo,
  adapter: Ecto.Adapters.Postgres,
  pool: Ecto.Adapters.SQL.Sandbox,
  database: "ds_test",
  username: "postgres",
  password: "postgres",
  hostname: "ds_test_db",
  port: 5432
