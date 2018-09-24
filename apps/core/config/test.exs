use Mix.Config

config :core, Core.Repo,
  adapter: Ecto.Adapters.Postgres,
  pool: Ecto.Adapters.SQL.Sandbox,
  database: "ds_test",
  hostname: System.get_env("DB_HOST")
