defmodule SynchronizerCrl.Web.Router do
  @moduledoc """
  The router provides a set of macros for generating routes
  that dispatch to specific controllers and actions.
  Those macros are named after HTTP verbs.

  More info at: https://hexdocs.pm/phoenix/Phoenix.Router.html
  """

  use SynchronizerCrl.Web, :router
  require Logger

  pipeline :api do
    plug(:accepts, ["json"])
    plug(:put_secure_browser_headers)
  end

  scope "/", SynchronizerCrl.Web do
    pipe_through(:api)

    post("/crl-url", SynchronizerCrlController, :index)
  end
end
