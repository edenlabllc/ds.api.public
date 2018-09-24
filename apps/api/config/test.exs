use Mix.Config

config :api, sql_sandbox: true

config :api, API.Web.Endpoint,
  http: [port: 4001],
  server: true

config :core, Core.Repo,
  pool: Ecto.Adapters.SQL.Sandbox,
  ownership_timeout: 120_000
