# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :core, ecto_repos: [Core.Repo], namespace: Core

config :core, Core.Repo,
  database: {:system, :string, "DB_NAME"},
  username: {:system, :string, "DB_USER"},
  password: {:system, :string, "DB_PASSWORD"},
  hostname: {:system, :string, "DB_HOST"},
  port: {:system, :integer, "DB_PORT", 5432},
  pool_size: {:system, :integer, "DB_POOL_SIZE", 10},
  timeout: 15_000
