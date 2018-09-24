defmodule DigitalSignature do
  @moduledoc """
  This is an entry point of digital_signature application.
  """
  use Application
  alias Confex.Resolver

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(DigitalSignature.NifService, [
        Confex.fetch_env!(:digital_signature, :certs_cache_ttl)
      ])
    ]

    opts = [strategy: :one_for_one, name: DigitalSignature.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def init(_key, config) do
    Resolver.resolve(config)
  end
end
