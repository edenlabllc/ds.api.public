defmodule SynchronizerCrl.Test do
  @moduledoc """
  test 3rd party services: providers crl
  and next update provide handling
  """
  use SynchronizerCrl.Web.ConnCase, async: false

  alias Core.Api, as: CoreApi
  alias SynchronizerCrl.CrlService

  doctest SynchronizerCrl.CrlService

  describe "gen server" do
    @tag :pending
    test "CRL Service started" do
      assert GenServer.whereis(CrlService)
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
      Enum.each(urls, &CrlService.update_crl_resource(&1))
      assert Enum.sort(urls) == Enum.sort(CoreApi.active_crls())
      assert GenServer.whereis(CrlService)
    end

    @tag :pending
    test "Get wrong CRL, update_crl_resource do not crash GenServer" do
      url = "http://not.existing.url"
      CrlService.update_crl_resource(url)
      assert GenServer.whereis(CrlService)
    end
  end

  describe "updates crl" do
    test "synchronize with new invalid crl do retry" do
      invalid_url = "ht://invalid.url"
      assert tref = CrlService.update_crl_resource(invalid_url)
      assert is_reference(tref)
      assert Process.cancel_timer(tref)
      refute [invalid_url] == CoreApi.active_crls()
    end

    @tag :pending
    test "synchronize with new valid crl success" do
      url = "http://uakey.com.ua/list-delta.crl"
      assert tref = CrlService.update_crl_resource(url)
      assert is_reference(tref)
      assert Process.cancel_timer(tref)
      assert [url] == CoreApi.active_crls()
    end
  end
end
