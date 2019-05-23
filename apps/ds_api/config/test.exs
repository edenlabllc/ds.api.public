use Mix.Config

config :ds_api,
  sql_sandbox: true,
  env: Mix.env(),
  rpc_worker: APIRpcWorkerMock

config :ds_api, API.Web.Endpoint,
  http: [port: 4001],
  server: true
