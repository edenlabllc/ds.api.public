defmodule OCSPService.Case do
  @moduledoc false
  use ExUnit.CaseTemplate

  alias Core.Repo
  alias Ecto.Adapters.SQL.Sandbox

  using do
    quote do
      alias Core.Repo

      # import Core.Factory
      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import Core.ModelCase
      import Mox
    end
  end

  setup tags do
    Supervisor.terminate_child(
      OCSPService.Supervisor,
      OCSPService.ReChecker
    )

    :ok = Sandbox.checkout(Repo)

    unless tags[:async] do
      Sandbox.mode(Repo, {:shared, self()})
    end

    assert {:ok, _} =
             Supervisor.restart_child(
               OCSPService.Supervisor,
               OCSPService.ReChecker
             )

    :ok
  end
end
