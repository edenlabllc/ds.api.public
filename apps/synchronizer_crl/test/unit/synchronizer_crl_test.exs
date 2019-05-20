defmodule SynchronizerCrl.Test do
  @moduledoc """
  test 3rd party services: providers crl
  and next update provide handling
  """
  use Core.ModelCase, async: false

  alias Core.CRL
  alias Core.CRLs
  alias SynchronizerCrl.Provider
  alias SynchronizerCrl.Worker

  describe "gen server" do
    @tag :pending
    test "CRL Service started" do
      assert GenServer.whereis(Worker)
    end

    @tag :pending
    test "Get CRL, update_crl_resource works" do
      urls = ~w(
        http://uakey.com.ua/list-delta.crl
        https://ca.informjust.ua/download/crls/CA-9A15A67B-Delta.crl
        http://acsk.privatbank.ua/crldelta/PB-Delta-S9.crl
        https://www.masterkey.ua/ca/crls/CA-4E6929B9-Delta.crl
        http://acsk.privatbank.ua/crl/PB-S11.crl
      )
      Enum.each(urls, &Worker.update_crl_resource(&1))
      assert Enum.sort(urls) == CRLs.active_crls() |> Enum.map(& &1.url) |> Enum.sort()
      assert GenServer.whereis(Worker)
    end

    @tag :pending
    test "Get wrong CRL, update_crl_resource do not crash GenServer" do
      url = "http://not.existing.url"
      Worker.update_crl_resource(url)
      assert GenServer.whereis(Worker)
    end
  end

  describe "updates crl" do
    test "synchronize with new invalid crl do retry" do
      invalid_url = "ht://invalid.url"
      Worker.update_crl_resource(invalid_url)
      assert [] = CRLs.active_crls()
    end

    @tag :pending
    test "synchronize with new valid crl success" do
      url = "http://uakey.com.ua/list-delta.crl"
      Worker.update_crl_resource(url)
      assert [%CRL{url: ^url}] = CRLs.active_crls()
    end

    @tag :pending
    test "Handle redirect 301 works" do
      url = "http://masterkey.ua/download/crls/CA-4E6929B9-Full.crl"
      assert {:ok, %HTTPoison.Response{status_code: 301}} = HTTPoison.get(url)
      assert {:ok, _, _} = Provider.get_revoked_certificates(url)
    end
  end
end
