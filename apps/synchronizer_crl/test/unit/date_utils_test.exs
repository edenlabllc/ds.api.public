defmodule DateUtilsTest do
  use ExUnit.Case
  import SynchronizerCrl.DateUtils

  doctest SynchronizerCrl.DateUtils

  test "convert nextUpdate rfc5280 works for charlist" do
    assert {:ok,
            %DateTime{
              day: 6,
              hour: 19,
              minute: 24,
              month: 8,
              second: 0,
              year: 2018
            }} = convert_date('180806192400Z')
  end

  test "convert nextUpdate rfc5280 works for string" do
    assert {:ok,
            %DateTime{
              day: 6,
              hour: 19,
              minute: 24,
              month: 8,
              second: 0,
              year: 2018
            }} = convert_date("180806192400Z")
  end

  test "convert nextUpdate rfc5280 error" do
    assert :error = convert_date(180_806_192_400)
  end

  test "next update time ok" do
    next_update = naive_datime_add(60)
    assert {:ok, _} = next_update_time(next_update)
  end

  test "next update time outdated 2 hours" do
    next_update = naive_datime_add(-60 * 60 * 2)
    assert {:ok, 108_000_000} = next_update_time(next_update)
  end

  test "next update time outdated 60 days" do
    next_update = naive_datime_add(-60 * 60 * 24 * 60)
    assert {:error, :outdated} = next_update_time(next_update)
  end

  test "next update time outdated 60 days if forse_synchronize" do
    next_update = naive_datime_add(-60 * 60 * 24 * 60)
    assert {:ok, 0} = next_update_time(next_update, true)
  end

  defp naive_datime_add(seconds) do
    NaiveDateTime.utc_now()
    |> NaiveDateTime.add(seconds)
    |> DateTime.from_naive!("Etc/UTC")
  end
end
