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
end
