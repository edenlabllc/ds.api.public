defmodule OCSPService.Application do
  @moduledoc false

  use Application
  import Supervisor.Spec, warn: false

  alias OCSPService.ReChecker

  def start(_type, _args) do
    Application.put_env(
      :kaffe,
      :consumer,
      Application.get_env(:ocsp_service, :kaffe_consumer)
    )

    children = [
      %{
        id: ReChecker,
        start: {ReChecker, :start_link, []}
      },
      %{
        id: Kaffe.GroupMemberSupervisor,
        start: {Kaffe.GroupMemberSupervisor, :start_link, []},
        type: :supervisor
      }
    ]

    opts = [strategy: :one_for_one, name: OCSPService.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
