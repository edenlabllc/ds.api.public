use Mix.Config

config :api, API.Web.Endpoint,
  http: [port: 4000],
  server: true,
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: []
