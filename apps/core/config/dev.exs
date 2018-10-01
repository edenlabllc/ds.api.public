use Mix.Config

config :core, Core.Repo, adapter: Ecto.Adapters.Postgres

# Configures Database
config :core, Core.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "ds_dev"
