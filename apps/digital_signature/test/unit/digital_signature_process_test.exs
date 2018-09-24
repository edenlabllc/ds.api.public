defmodule DigitalSignatureProcessLibTest do
  @moduledoc """
  test processPKCS7Data c nif
  """
  import DigitalSignatureTestHelper
  use ExUnit.Case, async: false

  describe "Must process all data correctly with all certs provided" do
    test "fail with incorrect data" do
      assert DigitalSignatureLib.processPKCS7Data([], get_certs(), true) ==
               {:error, "signed data argument is of incorrect type: must be Elixir string (binary)"}
    end

    test "fail with empty data" do
      {:ok, result} = DigitalSignatureLib.processPKCS7Data("", get_certs(), true)

      refute result.is_valid
      assert result.validation_error_message == "error processing signed data"
    end

    test "fails with incorrect signed data" do
      {:ok, result} = DigitalSignatureLib.processPKCS7Data("123", get_certs(), true)

      refute result.is_valid
      assert result.validation_error_message == "error processing signed data"
      assert result.content == ""
    end

    test "fails with complex incorrect signed data" do
      data = get_data("test/fixtures/incorrect_signed_data.json")
      signed_content = get_signed_content(data)

      assert {:ok, result} =
               DigitalSignatureLib.processPKCS7Data(
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

      assert {:ok, result} =
               DigitalSignatureLib.processPKCS7Data(
                 signed_content,
                 get_certs(),
                 true
               )

      assert result.is_valid
      assert decode_content(result) == data["content"]
      assert result.signer == atomize_keys(data["signer"])
    end

    test "can process signed legal entity 25 times in a row" do
      data = get_data("test/fixtures/signed_le1.json")
      signed_content = get_signed_content(data)
      certs = get_certs()

      expected_result = data["content"]
      expected_signer = atomize_keys(data["signer"])

      Enum.each(1..25, fn _ ->
        assert {:ok, result} =
                 DigitalSignatureLib.processPKCS7Data(
                   signed_content,
                   certs,
                   true
                 )

        assert result.is_valid
        assert decode_content(result) == expected_result
        assert result.signer == expected_signer
      end)
    end

    test "can process second signed legal entity" do
      data = get_data("test/fixtures/signed_le2.json")
      signed_content = get_signed_content(data)

      assert {:ok, result} =
               DigitalSignatureLib.processPKCS7Data(
                 signed_content,
                 get_certs(),
                 true
               )

      assert result.is_valid
      assert decode_content(result) == data["content"]
      assert result.signer == atomize_keys(data["signer"])
    end

    test "can process double signed declaration" do
      signed_content = File.read!("test/fixtures/double_hello.json.p7s.p7s")

      {:ok, result} = DigitalSignatureLib.processPKCS7Data(signed_content, get_certs(), true)

      assert result.is_valid
      assert is_binary(result.content)

      {:ok, second_result} = DigitalSignatureLib.processPKCS7Data(result.content, get_certs(), true)

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

      assert {:ok, result} =
               DigitalSignatureLib.processPKCS7Data(
                 signed_content,
                 get_certs(),
                 true
               )

      refute result.is_valid
      assert result.validation_error_message == "certificate timestamp expired"
    end

    test "can validate data signed with invalid Privat personal key" do
      data = File.read!("test/fixtures/hello_invalid.txt.sig")

      assert {:ok, result} = DigitalSignatureLib.processPKCS7Data(data, get_certs(), true)

      refute result.is_valid

      assert result.validation_error_message == "OCSP certificate verificaton failed"
    end

    test "can validate data signed with valid Privat personal key" do
      data = File.read!("test/fixtures/hello.txt.sig")

      assert {:ok, result} = DigitalSignatureLib.processPKCS7Data(data, get_certs(), true)

      {:ok, _, [%{access: url, ocsp_data: ocsp_data, data: data}]} =
        DigitalSignatureLib.retrivePKCS7Data(data, get_certs(), true)

      DigitalSignatureLib.checkCertOnline(data, ocsp_data, url)
      assert result.is_valid
      assert result.content == "{\"hello\": \"world\"}"
    end
  end

  describe "Must process all data or fail correclty when certs no available or available partially" do
    test "fails with correct signed data and without certs provided" do
      data = get_data("test/fixtures/signed_le1.json")
      signed_content = get_signed_content(data)

      {:ok, result} =
        DigitalSignatureLib.processPKCS7Data(
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

      {:ok, result} =
        DigitalSignatureLib.processPKCS7Data(
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

      {:ok, result} =
        DigitalSignatureLib.processPKCS7Data(
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

      {:ok, result} =
        DigitalSignatureLib.processPKCS7Data(
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

      assert {:ok, result} =
               DigitalSignatureLib.processPKCS7Data(
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
