defmodule API do
  @moduledoc """
  This is an entry point of API application.
  """
  use Application
  alias Confex.Resolver
  alias API.Web.Endpoint

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(API.Web.Endpoint, [])
    ]

    opts = [strategy: :one_for_one, name: API.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    Endpoint.config_change(changed, removed)
    :ok
  end

  @doc false
  def init(_key, config) do
    Resolver.resolve(config)
  end
end
