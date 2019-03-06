use Mix.Config

config :ds_api, API.Web.Endpoint,
  http: [port: 4000],
  server: true,
  debug_errors: false,
  code_reloader: true,
  check_origin: false,
  watchers: []
