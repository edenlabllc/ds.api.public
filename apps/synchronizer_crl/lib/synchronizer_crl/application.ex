defmodule SynchronizerCrl.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  import Supervisor.Spec, warn: false

  def start(_type, _args) do
    children = [worker(SynchronizerCrl.Worker, [])]
    opts = [strategy: :one_for_one, name: SynchronizerCrl.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
