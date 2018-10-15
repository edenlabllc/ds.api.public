defmodule CoreTest do
  use ExUnit.Case

  alias Core.Certificates
  alias Core.Repo
  alias Ecto.Adapters.SQL.Sandbox

  import Core.Factory

  setup do
    :ok = Sandbox.checkout(Repo)

    Sandbox.mode(Repo, {:shared, self()})
    :ok
  end

  test "check_revoked? true" do
    crl = insert(:crl)
    revoked = insert(:revoked, url: crl.url)

    assert {:ok, true} ==
             Certificates.check_revoked?(
               revoked.url,
               revoked.serial_number |> String.to_integer()
             )
  end

  test "check_revoked? false" do
    crl = insert(:crl)
    revoked = insert(:revoked, url: crl.url)

    assert {:ok, false} == Certificates.check_revoked?(revoked.url, 0)
  end

  test "revoked true" do
    crl = insert(:crl)
    revoked = insert(:revoked, url: crl.url)

    sn =
      revoked.serial_number
      |> String.to_integer()
      |> Integer.to_string(16)

    {:ok, revoked} = Certificates.revoked(revoked.url, sn)
    assert revoked
  end

  test "revoked false" do
    crl = insert(:crl)
    revoked = insert(:revoked, url: crl.url)

    {:ok, revoked} = Certificates.revoked(revoked.url, Integer.to_string(0, 16))

    refute revoked
  end
end
