defmodule DigitalSignatureRetriveLibTest do
  @moduledoc """
  test retrivePKCS7Data c nif
  """
  import DigitalSignatureTestHelper
  use ExUnit.Case, async: false

  describe "With/Without ocsp certificate no segfault" do
    test "with ocsp cert in db return ocsp_data in checklist" do
      data = get_data("test/fixtures/altersign.json")
      signed_content = get_signed_content(data)

      assert {:ok, result, ocsp_checklist} =
               DigitalSignatureLib.retrivePKCS7Data(
                 signed_content,
                 get_certs(),
                 true
               )

      assert result[:is_valid]

      assert [
               %{
                 access: "http://ocsp.altersign.com.ua/",
                 crl: "http://altersign.com.ua/esign/crls/CA-Altersign-2018-base.crl",
                 data: _,
                 delta_crl: "http://altersign.com.ua/esign/crls/CA-Altersign-2018-delta.crl",
                 ocsp_data: _,
                 root_data: _,
                 serial_number: "1ddd"
               }
             ] = ocsp_checklist
    end

    test "without ocsp cert in db does not return ocsp_data in checklist" do
      data = get_data("test/fixtures/altersign.json")
      signed_content = get_signed_content(data)
      certs = get_certs()
      general = Enum.map(certs[:general], fn %{root: root} -> %{root: root, ocsp: nil} end)
      certs = %{certs | general: general}

      assert {:ok, result, ocsp_checklist} =
               DigitalSignatureLib.retrivePKCS7Data(
                 signed_content,
                 certs,
                 true
               )

      assert result[:is_valid]

      assert [
               %{
                 access: "http://ocsp.altersign.com.ua/",
                 crl: "http://altersign.com.ua/esign/crls/CA-Altersign-2018-base.crl",
                 data: _,
                 delta_crl: "http://altersign.com.ua/esign/crls/CA-Altersign-2018-delta.crl",
                 root_data: _,
                 serial_number: "1ddd"
               }
             ] = ocsp_checklist

      refute ocsp_checklist[:ocsp_data]
    end
  end

  describe "Must process all data correctly with all certs provided" do
    test "fail with incorrect data" do
      assert DigitalSignatureLib.retrivePKCS7Data([], get_certs(), true) ==
               {:error, "signed data argument is of incorrect type: must be Elixir string (binary)"}
    end

    test "fail with empty data" do
      {:ok, result, _} = DigitalSignatureLib.retrivePKCS7Data("", get_certs(), true)

      refute result.is_valid
      assert result.validation_error_message == "error processing signed data"
    end

    test "fails with incorrect signed data" do
      {:ok, result, _} = DigitalSignatureLib.retrivePKCS7Data("123", get_certs(), true)

      refute result.is_valid
      assert result.validation_error_message == "error processing signed data"
      assert result.content == ""
    end

    test "fails with complex incorrect signed data" do
      data = get_data("test/fixtures/incorrect_signed_data.json")
      signed_content = get_signed_content(data)

      assert {:ok, result, _} =
               DigitalSignatureLib.retrivePKCS7Data(
                 signed_content,
                 get_certs(),
                 true
               )

      refute result.is_valid
      assert result.validation_error_message == "error processing signed data"
    end

    test "can process signed legal entity" do
      data = get_data("test/fixtures/signed_le1.json")
      signed_content = get_signed_content(data)

      assert {:ok, result, ocsp_checklist} =
               DigitalSignatureLib.retrivePKCS7Data(
                 signed_content,
                 get_certs(),
                 true
               )

      assert result.is_valid

      assert [
               %{
                 access: "http://acskidd.gov.ua/services/ocsp/",
                 crl: "http://acskidd.gov.ua/download/crls/ACSKIDDDFS-Full.crl",
                 delta_crl: "http://acskidd.gov.ua/download/crls/ACSKIDDDFS-Delta.crl",
                 ocsp_data: _,
                 root_data: _,
                 serial_number: "33b6cb7bf721b9ce040000004c5a250041875900"
               }
             ] = ocsp_checklist
    end

    test "can process signed legal entity 25 times in a row" do
      data = get_data("test/fixtures/signed_le1.json")
      signed_content = get_signed_content(data)
      certs = get_certs()

      Enum.each(1..25, fn _ ->
        assert {:ok, result, ocsp_checklist} =
                 DigitalSignatureLib.retrivePKCS7Data(
                   signed_content,
                   certs,
                   true
                 )

        assert result.is_valid

        assert [
                 %{
                   access: "http://acskidd.gov.ua/services/ocsp/",
                   crl: "http://acskidd.gov.ua/download/crls/ACSKIDDDFS-Full.crl",
                   delta_crl: "http://acskidd.gov.ua/download/crls/ACSKIDDDFS-Delta.crl",
                   serial_number: "33b6cb7bf721b9ce040000004c5a250041875900"
                 }
               ] = ocsp_checklist
      end)
    end

    test "can process second signed legal entity" do
      data = get_data("test/fixtures/signed_le2.json")
      signed_content = get_signed_content(data)

      assert {:ok, result, ocsp_checklist} =
               DigitalSignatureLib.retrivePKCS7Data(
                 signed_content,
                 get_certs(),
                 true
               )

      assert result.is_valid
      assert decode_content(result) == data["content"]
      assert result.signer == atomize_keys(data["signer"])

      assert [
               %{
                 access: "http://acskidd.gov.ua/services/ocsp/",
                 crl: "http://acskidd.gov.ua/download/crls/ACSKIDDDFS-Full.crl",
                 delta_crl: "http://acskidd.gov.ua/download/crls/ACSKIDDDFS-Delta.crl",
                 data: _,
                 serial_number: "33b6cb7bf721b9ce040000000d1d2500aeb15800"
               }
             ] = ocsp_checklist
    end

    test "can process double signed declaration" do
      signed_content = File.read!("test/fixtures/double_hello.json.p7s.p7s")

      {:ok, result, first_ocsp_checklist} = DigitalSignatureLib.retrivePKCS7Data(signed_content, get_certs(), true)

      assert [
               %{
                 access: "http://acskidd.gov.ua/services/ocsp/",
                 crl: "http://acskidd.gov.ua/download/crls/CA-20B4E4ED-Full.crl",
                 delta_crl: "http://acskidd.gov.ua/download/crls/CA-20B4E4ED-Delta.crl",
                 data: _,
                 serial_number: "20b4e4ed0d30998c040000006e121e0069736000"
               }
             ] = first_ocsp_checklist

      assert result.is_valid
      assert is_binary(result.content)

      {:ok, second_result, second_ocsp_checklist} =
        DigitalSignatureLib.retrivePKCS7Data(result.content, get_certs(), true)

      assert [
               %{
                 access: "http://acskidd.gov.ua/services/ocsp/",
                 crl: "http://acskidd.gov.ua/download/crls/CA-20B4E4ED-Full.crl",
                 delta_crl: "http://acskidd.gov.ua/download/crls/CA-20B4E4ED-Delta.crl",
                 data: _,
                 serial_number: "20b4e4ed0d30998c040000006e121e0069736000"
               }
             ] = second_ocsp_checklist

      assert second_result.is_valid
      assert second_result.content == "{\n\"double\": \"hello world\"\n}\n"
    end

    test "can get data from signed declaration" do
      data = File.read!("test/fixtures/hello.txt.sig")

      {:ok, 1} = DigitalSignatureLib.checkPKCS7Data(data)
    end

    test "can return correct result for incorrect data" do
      data = File.read!("test/fixtures/hello.txt")

      {:error, :signed_data_load} = DigitalSignatureLib.checkPKCS7Data(data)
    end

    test "processing signed declaration with outdated signature" do
      data = get_data("test/fixtures/outdated_cert.json")
      signed_content = get_signed_content(data)

      assert {:ok, result, ocsp_checklist} =
               DigitalSignatureLib.retrivePKCS7Data(
                 signed_content,
                 get_certs(),
                 true
               )

      refute result.is_valid
      assert result.validation_error_message == "certificate timestamp expired"
      assert [] == ocsp_checklist
    end

    test "can validate data signed with valid Privat personal key" do
      data = File.read!("test/fixtures/hello.txt.sig")
      assert {:ok, result, ocsp_checklist} = DigitalSignatureLib.retrivePKCS7Data(data, get_certs(), true)
      assert result.is_valid
      assert %{"text" => "Hello World"} == Jason.decode!(result.content)

      assert [
               %{
                 access: "http://acskidd.gov.ua/services/ocsp/",
                 crl: "http://acskidd.gov.ua/download/crls/ACSKIDDDFS-Full.crl",
                 delta_crl: "http://acskidd.gov.ua/download/crls/ACSKIDDDFS-Delta.crl",
                 serial_number: "33b6cb7bf721b9ce040000004c5a250041875900"
               }
             ] = ocsp_checklist
    end
  end

  describe "Must process all data or fail correclty when certs no available or available partially" do
    test "fails with correct signed data and without certs provided" do
      data = get_data("test/fixtures/signed_le1.json")
      signed_content = get_signed_content(data)

      {:ok, result, _} =
        DigitalSignatureLib.retrivePKCS7Data(
          signed_content,
          %{general: [], tsp: []},
          true
        )

      refute result.is_valid

      assert result.validation_error_message == "matching ROOT certificate not found"
    end

    test "fails with correct signed data and only General certs provided" do
      data = get_data("test/fixtures/signed_le1.json")
      signed_content = get_signed_content(data)

      %{general: general, tsp: _tsp} = get_certs()

      {:ok, result, _} =
        DigitalSignatureLib.retrivePKCS7Data(
          signed_content,
          %{general: general, tsp: []},
          true
        )

      refute result.is_valid

      assert result.validation_error_message == "matching TSP certificate not found"
    end

    test "fails with correct signed data and only TSP certs provided" do
      data = get_data("test/fixtures/signed_le1.json")
      signed_content = get_signed_content(data)

      %{general: _general, tsp: tsp} = get_certs()

      {:ok, result, _} =
        DigitalSignatureLib.retrivePKCS7Data(
          signed_content,
          %{general: [], tsp: tsp},
          true
        )

      refute result.is_valid

      assert result.validation_error_message == "matching ROOT certificate not found"
    end

    test "Validates signed data with only ROOT certs provided" do
      data = get_data("test/fixtures/signed_le1.json")
      signed_content = get_signed_content(data)

      general = [
        %{
          root: File.read!("test/fixtures/CA-DFS.cer"),
          ocsp: nil
        }
      ]

      {:ok, result, _} =
        DigitalSignatureLib.retrivePKCS7Data(
          signed_content,
          %{general: general, tsp: []},
          true
        )

      refute result.is_valid

      assert result.validation_error_message == "matching TSP certificate not found"
    end

    test "can validate data with invalid entries in siganture_info" do
      data = get_data("test/fixtures/no_cert_and_invalid_signer.json")
      signed_content = get_signed_content(data)

      assert {:ok, result, _} =
               DigitalSignatureLib.retrivePKCS7Data(
                 signed_content,
                 get_certs(),
                 true
               )

      refute result.is_valid

      assert result.validation_error_message == "matching ROOT certificate not found"

      # this field contains invalid (non UTF-8) data inside the signed package
      # - so we are returing an empty string
      assert result.signer.organization_name == ""

      # this field contains invalid (non UTF-8) data inside the signed package
      # - so we are returing an empty string
      assert result.signer.organizational_unit_name == ""
    end
  end
end
