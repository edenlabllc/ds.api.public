defmodule SynchronizerCrl.Test do
  @moduledoc """
  test 3rd party services: providers crl
  and next update provide handling
  """
  use ExUnit.Case, async: false
  alias Core.Repo
  alias Ecto.Adapters.SQL.Sandbox
  alias SynchronizerCrl.CrlService

  doctest SynchronizerCrl.CrlService

  setup do
    assert :ok == Sandbox.checkout(Repo)
    Sandbox.mode(Repo, {:shared, self()})
  end

  test "CRL Service started" do
    assert GenServer.whereis(CrlService)
  end

  test "Get CRL works" do
    urls = ~w(
    https://ca.informjust.ua/download/crls/CA-9A15A67B-Delta.crl
    http://uakey.com.ua/list-delta.crl
    http://acsk.privatbank.ua/crldelta/PB-Delta-S9.crl
    )

    Enum.each(urls, fn url ->
      assert %{^url => tref} = CrlService.update_url_state(url, %{})
      Process.cancel_timer(tref)
      assert GenServer.whereis(CrlService)
    end)

    assert GenServer.whereis(CrlService)
  end

  test "Get wrong CRL do not crash GenServer" do
    url = "http://not.existing.url"
    CrlService.update_url_state(url, %{})
    assert GenServer.whereis(CrlService)
  end

  test "next update time ok" do
    next_update =
      NaiveDateTime.utc_now()
      |> NaiveDateTime.add(60)
      |> DateTime.from_naive!("Etc/UTC")

    assert {:ok, _} = CrlService.next_update_time(next_update)
  end

  test "next update time outdated 2 hours " do
    next_update =
      NaiveDateTime.utc_now()
      |> NaiveDateTime.add(-60 * 60 * 2)
      |> DateTime.from_naive!("Etc/UTC")

    assert {:ok, 108_000_000} = CrlService.next_update_time(next_update)
  end

  test "next update time outdated 60 days " do
    next_update =
      NaiveDateTime.utc_now()
      |> NaiveDateTime.add(-60 * 60 * 24 * 60)
      |> DateTime.from_naive!("Etc/UTC")

    assert {:error, :outdated} = CrlService.next_update_time(next_update)
  end
end
