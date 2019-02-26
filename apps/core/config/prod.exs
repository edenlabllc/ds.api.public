# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :core, ecto_repos: [Core.Repo], namespace: Core

# Configure crl api
config :core, Core.Api, sn_chunk_limit: 20_000

# Databases configuration
config :core, Core.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "${DB_NAME}",
  username: "${DB_USER}",
  password: "${DB_PASSWORD}",
  hostname: "${DB_HOST}",
  port: "${DB_PORT}",
  pool_size: "${DB_POOL_SIZE}",
  timeout: 15_000,
  pool_timeout: 15_000,
  loggers: [{Ecto.LoggerJSON, :log, [:info]}]

config :kaffe,
  producer: [endpoints: {:system, :string, "KAFKA_BROKERS"}]
