defmodule CoreApiTest do
  use ExUnit.Case, async: false
  alias Core.Api
  alias Core.Crl
  alias Core.Repo
  alias Core.RevokedSN
  alias Ecto.Adapters.SQL.Sandbox

  import Core.Factory

  setup do
    :ok = Sandbox.checkout(Repo)

    Sandbox.mode(Repo, {:shared, self()})
    :ok
  end

  test "list urls works" do
    insert(:crl, url: "https://crl.com")
    assert ["https://crl.com"] = Api.active_crls()
  end

  test "remove_url/1 works" do
    insert(:crl, url: "https://crl.com")
    Api.remove_url("https://crl.com")
    assert [] = Api.active_crls()
  end

  test "get serial" do
    url = "url.com"
    sn = "1234"
    insert(:revoked, serial_number: sn, url: url)
    assert %RevokedSN{serial_number: ^sn, url: ^url} = Api.get_serial(url, 1234)
  end

  test "write new url" do
    url = "crl.com"
    Api.write_url(url, DateTime.utc_now())
    assert [^url] = Api.active_crls()
  end

  test "update existing url" do
    crl = insert(:crl)
    url = crl.url
    dt = DateTime.utc_now()
    Api.write_url(url, dt)
    assert [%Crl{url: ^url, next_update: ^dt}] = Repo.all(Crl)
  end

  test "write new serials" do
    url = "crl.com"
    serials = 1..3
    Api.write_serials(url, serials)

    Enum.each(serials, fn s ->
      sn = Integer.to_string(s)
      assert %RevokedSN{serial_number: ^sn} = Api.get_serial(url, s)
    end)
  end

  test "update serial numbers" do
    url = "crl.com"
    insert(:revoked, serial_number: "0", url: url)
    serials = 1..3
    Api.write_serials(url, serials)

    Enum.each(serials, fn s ->
      sn = Integer.to_string(s)
      assert %RevokedSN{serial_number: ^sn} = Api.get_serial(url, s)
    end)

    refute Api.get_serial(url, 0)
  end

  test "update_serials/3 ok" do
    url = "crl.com"
    insert(:revoked, serial_number: "0", url: url)
    serials = 1..3
    Api.update_serials(url, DateTime.utc_now(), serials)

    Enum.each(serials, fn s ->
      sn = Integer.to_string(s)
      assert %RevokedSN{serial_number: ^sn} = Api.get_serial(url, s)
    end)

    refute Api.get_serial(url, 0)
  end
end
