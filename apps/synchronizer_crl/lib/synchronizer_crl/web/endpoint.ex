defmodule SynchronizerCrl.Web.Endpoint do
  @moduledoc """
  Phoenix Endpoint for digital_signature application.
  """
  use Phoenix.Endpoint, otp_app: :synchronizer_crl
  use SynchronizerCrl.Web, :view

  alias Confex.Resolver

  if Application.get_env(:synchronizer_crl, :sql_sandbox) do
    plug(Phoenix.Ecto.SQL.Sandbox)
  end

  plug(Plug.RequestId)
  plug(Plug.LoggerJSON, level: Logger.level())

  plug(
    Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  )

  plug(Plug.MethodOverride)
  plug(Plug.Head)

  plug(SynchronizerCrl.Web.Router)

  @doc """
  Dynamically loads configuration from the system environment
  on startup.

  It receives the endpoint configuration from the config files
  and must return the updated configuration.
  """
  def init(_key, config) do
    config = Resolver.resolve!(config)

    unless config[:secret_key_base] do
      raise "Set SECRET_KEY environment variable!"
    end

    {:ok, config}
  end
end
