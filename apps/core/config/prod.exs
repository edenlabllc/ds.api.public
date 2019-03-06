# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :core, ecto_repos: [Core.Repo], namespace: Core

# Configure crl api
config :core, Core.Api, sn_chunk_limit: 20_000

config :core, Core.Repo,
  database: {:system, :string, "DB_NAME"},
  username: {:system, :string, "DB_USER"},
  password: {:system, :string, "DB_PASSWORD"},
  hostname: {:system, :string, "DB_HOST"},
  port: {:system, :integer, "DB_PORT", 5432},
  pool_size: {:system, :integer, "DB_POOL_SIZE", 10},
  timeout: 15_000

config :kaffe,
  producer: [endpoints: {:system, :string, "KAFKA_BROKERS"}]
