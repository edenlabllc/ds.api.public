defmodule API do
  @moduledoc """
  This is an entry point of API application.
  """
  use Application

  alias API.Web.Endpoint

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    endpoint = supervisor(API.Web.Endpoint, [])

    children =
      if Application.get_env(:ds_api, :env) == :prod do
        [endpoint, {Cluster.Supervisor, [Application.get_env(:ds_api, :topologies), [name: API.ClusterSupervisor]]}]
      else
        [endpoint]
      end

    opts = [strategy: :one_for_one, name: API.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    Endpoint.config_change(changed, removed)
    :ok
  end
end
