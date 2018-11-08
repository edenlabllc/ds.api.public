use Mix.Config

config :ds_api, sql_sandbox: true

config :ds_api, API.Web.Endpoint,
  http: [port: 4001],
  server: true
