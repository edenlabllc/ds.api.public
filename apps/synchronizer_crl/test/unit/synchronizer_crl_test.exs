defmodule SynchronizerCrl.Test do
  @moduledoc """
  test 3rd party services: providers crl
  and next update provide handling
  """
  use SynchronizerCrl.Web.ConnCase, async: false
  alias Core.Api, as: CoreApi
  alias SynchronizerCrl.CrlService
  alias SynchronizerCrl.DateUtils

  doctest SynchronizerCrl.CrlService

  test "CRL Service started" do
    assert GenServer.whereis(CrlService)
  end

  test "Get CRL, update_crl_resource works" do
    urls = ~w(
    http://uakey.com.ua/list-delta.crl
    https://ca.informjust.ua/download/crls/CA-9A15A67B-Delta.crl
    http://acsk.privatbank.ua/crldelta/PB-Delta-S9.crl
    https://www.masterkey.ua/ca/crls/CA-4E6929B9-Delta.crl
    http://acsk.privatbank.ua/crl/PB-S11.crl
    )

    Enum.each(urls, fn url ->
      CrlService.update_crl_resource(url)
    end)

    assert Enum.sort(urls) == Enum.sort(CoreApi.active_crls())
    assert GenServer.whereis(CrlService)
  end

  test "Get wrong CRL, update_crl_resource do not crash GenServer" do
    url = "http://not.existing.url"
    CrlService.update_crl_resource(url)
    assert GenServer.whereis(CrlService)
  end

  test "next update time ok" do
    next_update =
      NaiveDateTime.utc_now()
      |> NaiveDateTime.add(60)
      |> DateTime.from_naive!("Etc/UTC")

    assert {:ok, _} = DateUtils.next_update_time(next_update)
  end

  test "next update time outdated 2 hours " do
    next_update =
      NaiveDateTime.utc_now()
      |> NaiveDateTime.add(-60 * 60 * 2)
      |> DateTime.from_naive!("Etc/UTC")

    assert {:ok, 108_000_000} = DateUtils.next_update_time(next_update)
  end

  test "next update time outdated 60 days " do
    next_update =
      NaiveDateTime.utc_now()
      |> NaiveDateTime.add(-60 * 60 * 24 * 60)
      |> DateTime.from_naive!("Etc/UTC")

    assert {:error, :outdated} = DateUtils.next_update_time(next_update)
  end

  test "next update time outdated 60 days if check " do
    next_update =
      NaiveDateTime.utc_now()
      |> NaiveDateTime.add(-60 * 60 * 24 * 60)
      |> DateTime.from_naive!("Etc/UTC")

    assert {:ok, 0} = DateUtils.next_update_time(next_update, true)
  end
end
