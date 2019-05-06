# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :ds_api, API.Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "kM4g3grYc77xl0Zglf381h8g6EgOBSH18TbWwMB1UCdWHxFFkIZcF8Ci3w9ZtLCF",
  render_errors: [view: EView.Views.PhoenixError, accepts: ~w(json)],
  instrumenters: [LoggerJSON.Phoenix.Instruments]

config :ds_api,
  topologies: [
    k8s_ops: [
      strategy: Elixir.Cluster.Strategy.Kubernetes,
      config: [
        mode: :dns,
        kubernetes_node_basename: "ds",
        kubernetes_selector: "app=api",
        kubernetes_namespace: "ops",
        polling_interval: 10_000
      ]
    ]
  ]

config :phoenix, :format_encoders, json: Jason

import_config "#{Mix.env()}.exs"
