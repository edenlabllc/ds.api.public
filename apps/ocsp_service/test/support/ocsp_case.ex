defmodule OCSPService.Case do
  @moduledoc false
  use ExUnit.CaseTemplate
  alias Core.Repo
  alias Ecto.Adapters.SQL.Sandbox

  setup tags do
    :ok = Sandbox.checkout(Repo)

    Supervisor.terminate_child(
      OCSPService.Supervisor,
      OCSPService.ReChecker
    )

    assert {:ok, _} =
             Supervisor.restart_child(
               OCSPService.Supervisor,
               OCSPService.ReChecker
             )

    unless tags[:async] do
      Sandbox.allow(Repo, self(), self())
      Sandbox.mode(Repo, {:shared, self()})
    end

    :ok
  end
end
