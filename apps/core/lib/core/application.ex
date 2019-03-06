defmodule Core.Application do
  @moduledoc false

  use Application
  import Supervisor.Spec, warn: false

  def start(_type, _args) do
    children = [
      supervisor(Core.Repo, [])
    ]

    opts = [strategy: :one_for_one, name: Core.Supervisor]
    :telemetry.attach("log-handler", [:core, :repo, :query], &Core.TelemetryHandler.handle_event/4, nil)
    Supervisor.start_link(children, opts)
  end
end
