use Mix.Config

config :api, sql_sandbox: true

config :api, API.Web.Endpoint,
  http: [port: 4001],
  server: true
