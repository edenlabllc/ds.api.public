defmodule OCSPServiceTest do
  use ExUnit.Case

  import DigitalSignatureTestHelper

  alias Core.InvalidContent
  alias Core.InvalidContents
  alias Core.Repo
  alias Ecto.Adapters.SQL.Sandbox

  setup do
    :ok = Sandbox.checkout(Repo)

    Sandbox.mode(Repo, {:shared, self()})
    :ok
  end

  describe "signatures from kafka correct check" do
    @tag :pending
    test "first valid certs" do
      signed_content = File.read!("test/fixtures/signed_content.p7s")

      expires_at =
        NaiveDateTime.add(NaiveDateTime.utc_now(), 180_000, :millisecond)

      assert {:ok, result, [signature]} =
               DigitalSignatureLib.retrivePKCS7Data(
                 signed_content,
                 get_certs(),
                 true
               )

      assert {:ok, true} =
               DigitalSignature.NifServiceAPI.check_online(
                 signature[:access],
                 signature[:data],
                 signature[:ocsp_data],
                 expires_at,
                 50000
               )

      sign = %{
        crl: "http://acskidd.gov.ua/download/crls/CA-20B4E4ED-Full.crl",
        data:
          "MHAwbjBsMGowaDAMBgoqhiQCAQEBAQIBBCDHt8i02fO2kiLx+NVu4BPGjGVDHR09x/Tt4HU5K0wytwQgILTk7Q0wmYy+MGoHfWmaMnMjiukJCHHWFjcOGOV21H8CFCC05O0NMJmMBAAAADgCJwAr32AA",
        access: "http://acskidd.gov.ua/services/ocsp/",
        delta_crl: "http://acskidd.gov.ua/download/crls/CA-20B4E4ED-Delta.crl",
        ocsp_data:
          "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",
        root_data:
          "MIIGUDCCBcygAwIBAgIUPbc+e/DVdbIBAAAAAQAAAJQAAAAwDQYLKoYkAgEBAQEDAQEwgfoxPzA9BgNVBAoMNtCc0ZbQvdGW0YHRgtC10YDRgdGC0LLQviDRjtGB0YLQuNGG0ZbRlyDQo9C60YDQsNGX0L3QuDExMC8GA1UECwwo0JDQtNC80ZbQvdGW0YHRgtGA0LDRgtC+0YAg0IbQotChINCm0JfQnjFJMEcGA1UEAwxA0KbQtdC90YLRgNCw0LvRjNC90LjQuSDQt9Cw0YHQstGW0LTRh9GD0LLQsNC70YzQvdC40Lkg0L7RgNCz0LDQvTEZMBcGA1UEBQwQVUEtMDAwMTU2MjItMjAxNzELMAkGA1UEBhMCVUExETAPBgNVBAcMCNCa0LjRl9CyMB4XDTE4MDIwODE2NTQwMFoXDTIzMDIwODE2NTQwMFowggFVMVQwUgYDVQQKDEvQhtC90YTQvtGA0LzQsNGG0ZbQudC90L4t0LTQvtCy0ZbQtNC60L7QstC40Lkg0LTQtdC/0LDRgNGC0LDQvNC10L3RgiDQlNCk0KExXjBcBgNVBAsMVdCj0L/RgNCw0LLQu9GW0L3QvdGPICjRhtC10L3RgtGAKSDRgdC10YDRgtC40YTRltC60LDRhtGW0Zcg0LrQu9GO0YfRltCyINCG0JTQlCDQlNCk0KExYjBgBgNVBAMMWdCQ0LrRgNC10LTQuNGC0L7QstCw0L3QuNC5INGG0LXQvdGC0YAg0YHQtdGA0YLQuNGE0ZbQutCw0YbRltGXINC60LvRjtGH0ZbQsiDQhtCU0JQg0JTQpNChMRkwFwYDVQQFDBBVQS0zOTM4NDQ3Ni0yMDE4MQswCQYDVQQGEwJVQTERMA8GA1UEBwwI0JrQuNGX0LIwgfIwgckGCyqGJAIBAQEBAwEBMIG5MHUwBwICAQECAQwCAQAEIRC+49tq6p4fhleMRcEllP+UI5Sn1zj5GH5lFQFylPTOAQIhAIAAAAAAAAAAAAAAAAAAAABnWSE68YLph9PhdxSQfUcNBCG2D9LY3OipNCPGEBvKkcR6AH5sMAsmzVVsmw59IO8pKgAEQKnW60XxPHCCgMSWeyMfXq32WOukwDcpHTjZa/Alyk4X+OlyDcYVtDool18Lwd6jZDi1ZOosF5/QEj5tuPrFeQQDJAAEIdmxRd9RLjkNkjiOsvvx9fTKH2HVK8Sp4BPKv4y6IvTaAKOCAjMwggIvMCkGA1UdDgQiBCAgtOTtDTCZjL4wagd9aZoycyOK6QkIcdYWNw4Y5XbUfzAOBgNVHQ8BAf8EBAMCAQYwGQYDVR0gAQH/BA8wDTALBgkqhiQCAQEBAgIwga4GA1UdEQSBpjCBo6BWBgwrBgEEAYGXRgEBBAKgRgxEMDQ2NTUsINC8LiDQmtC40ZfQsiwg0JvRjNCy0ZbQstGB0YzQutCwINC/0LvQvtGJ0LAsINCx0YPQtNC40L3QvtC6IDigIgYMKwYBBAGBl0YBAQQBoBIMECszOCgwNDQpIDI4NDAwMTCCDmFjc2tpZGQuZ292LnVhgRVpbmZvcm1AYWNza2lkZC5nb3YudWEwEgYDVR0TAQH/BAgwBgEB/wIBADAeBggrBgEFBQcBAwEB/wQPMA0wCwYJKoYkAgEBAQIBMCsGA1UdIwQkMCKAIL23Pnvw1XWySAJ4PZ4FqVCXdsF196yBdnQIB5Z6NCAUMEIGA1UdHwQ7MDkwN6A1oDOGMWh0dHA6Ly9jem8uZ292LnVhL2Rvd25sb2FkL2NybHMvQ1pPLTIwMTctRnVsbC5jcmwwQwYDVR0uBDwwOjA4oDagNIYyaHR0cDovL2N6by5nb3YudWEvZG93bmxvYWQvY3Jscy9DWk8tMjAxNy1EZWx0YS5jcmwwPAYIKwYBBQUHAQEEMDAuMCwGCCsGAQUFBzABhiBodHRwOi8vY3pvLmdvdi51YS9zZXJ2aWNlcy9vY3NwLzANBgsqhiQCAQEBAQMBAQNvAARsDDxAufVOmldB29zclD8JEP70GxyPKzL0JeTbQe/Ng7N15YQr063z78qOgsSOiwlQGi6AH1sMhCn00TxCk0rkOST86Ico4hyINtpibItxL7K4ZfapKL326ABAxQfFN+/tBygFsffofLLtm2EX",
        serial_number: "20b4e4ed0d30998c04000000380227002bdf6000"
      }

      assert %{
               sign
               | root_data: Base.decode64!(sign[:root_data]),
                 ocsp_data: Base.decode64!(sign[:ocsp_data]),
                 data: Base.decode64!(sign[:data])
             } == signature

      {:ok, result} =
        DigitalSignatureLib.processPKCS7Data(signed_content, get_certs(), true)

      assert result.is_valid
    end

    @tag :pending
    test "second valid certs" do
      signed_content = File.read!("test/fixtures/signed_content2.p7s")

      {:ok, result} =
        DigitalSignatureLib.processPKCS7Data(signed_content, get_certs(), true)

      assert result.is_valid

      expires_at =
        NaiveDateTime.add(NaiveDateTime.utc_now(), 180_000, :millisecond)

      assert {:ok, result, [signature]} =
               DigitalSignatureLib.retrivePKCS7Data(
                 signed_content,
                 get_certs(),
                 true
               )

      assert {:ok, true} =
               DigitalSignature.NifServiceAPI.check_online(
                 signature[:access],
                 signature[:data],
                 signature[:ocsp_data],
                 expires_at,
                 50000
               )
    end
  end

  describe "store content to db" do
    test "success store content" do
      data = get_data("test/fixtures/signed_le1.json")
      signed_content = get_signed_content(data)

      {:ok, content, [signature] = signatures} =
        DigitalSignatureLib.retrivePKCS7Data(signed_content, get_certs(), true)

      assert {:ok, id} =
               InvalidContents.store_invalid_content(signatures, content)

      %InvalidContent{signatures: [db_signature], content: db_content} =
        invalid_conetn_record = InvalidContents.get_by_id(id)

      assert invalid_conetn_record == InvalidContents.random_invalid_content()
      assert db_signature == signature

      assert Jason.encode!(content) == db_content

      InvalidContents.delete(id)
      assert nil == InvalidContents.random_invalid_content()
    end

    test "update content" do
      assert {:ok, id} = InvalidContents.store_invalid_content([], "")

      assert {:ok, _} =
               InvalidContents.update_invalid_content(id, %{notified: true})

      assert %InvalidContent{notified: true, id: ^id} =
               InvalidContents.get_by_id(id)
    end
  end
end
