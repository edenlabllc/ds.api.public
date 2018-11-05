defmodule SynchronizerCrl.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  import Supervisor.Spec, warn: false

  alias Confex.Resolver
  alias SynchronizerCrl.Web.Endpoint

  def start(_type, _args) do
    children = [
      supervisor(SynchronizerCrl.Web.Endpoint, []),
      worker(SynchronizerCrl.CrlService, [])
    ]

    opts = [strategy: :one_for_one, name: SynchronizerCrl.Supervisor]
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
