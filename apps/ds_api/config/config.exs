# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :ds_api, API.Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "kM4g3grYc77xl0Zglf381h8g6EgOBSH18TbWwMB1UCdWHxFFkIZcF8Ci3w9ZtLCF",
  render_errors: [view: EView.Views.PhoenixError, accepts: ~w(json)]

import_config "#{Mix.env()}.exs"
