defmodule DigitalSignatureCheckOCSPLibTest do
  @moduledoc """
  OCSP check only, check in single nif call(process pkcs7data) and
  check in another proccess (retrive pkcs7data and check cert online)
  Summury main test for nifs
  test checkCertOnline c nif, retrive and process PKCS7Data
  """
  import DigitalSignatureTestHelper
  use ExUnit.Case, async: false

  describe "Must process all data correctly online" do
    test "can process signed legal entity" do
      data = get_data("test/fixtures/signed_le1.json")
      signed_content = get_signed_content(data)

      {:ok, _, [%{access: url, ocsp_data: ocsp_data, data: certdata}]} =
        DigitalSignatureLib.retrivePKCS7Data(signed_content, get_certs(), true)

      assert {:ok, true} == DigitalSignatureLib.checkCertOnline(certdata, ocsp_data, url)
    end

    test "can process signed legal entity 25 times in a row" do
      data = get_data("test/fixtures/signed_le1.json")
      signed_content = get_signed_content(data)

      Enum.each(1..25, fn _ ->
        {:ok, _, [%{access: url, ocsp_data: ocsp_data, data: certdata}]} =
          DigitalSignatureLib.retrivePKCS7Data(signed_content, get_certs(), true)

        assert {:ok, true} == DigitalSignatureLib.checkCertOnline(certdata, ocsp_data, url)
      end)
    end

    test "can process second signed legal entity" do
      data = get_data("test/fixtures/signed_le2.json")
      signed_content = get_signed_content(data)

      {:ok, result} =
        DigitalSignatureLib.processPKCS7Data(
          signed_content,
          get_certs(),
          true
        )

      {:ok, _, [%{access: url, ocsp_data: ocsp_data, data: certdata}]} =
        DigitalSignatureLib.retrivePKCS7Data(signed_content, get_certs(), true)

      assert {:ok, true} == DigitalSignatureLib.checkCertOnline(certdata, ocsp_data, url)

      assert result.is_valid
      assert decode_content(result) == data["content"]
      assert result.signer == atomize_keys(data["signer"])
    end

    test "can validate data signed with valid Privat personal key" do
      data = File.read!("test/fixtures/hello.txt.sig")

      {:ok, result_process} = DigitalSignatureLib.processPKCS7Data(data, get_certs(), true)

      {:ok, result_retrive, [%{access: url, ocsp_data: ocsp_data, data: data}]} =
        DigitalSignatureLib.retrivePKCS7Data(data, get_certs(), true)

      assert {:ok, true} == DigitalSignatureLib.checkCertOnline(data, ocsp_data, url)
      assert result_process.is_valid
      assert result_retrive.is_valid
      assert %{"text" => "Hello World"} == Jason.decode!(result_process.content)
      assert result_retrive.content == result_process.content
    end
  end

  describe "test revoked certificate online ocsp" do
    test "processing signed with revoked Privat personal key" do
      data = get_data("test/fixtures/hello_revoked.json")
      {:ok, signed_content} = Base.decode64(Map.get(data, "signed_content"))

      {:ok, result_process} = DigitalSignatureLib.processPKCS7Data(signed_content, get_certs(), true)

      {:ok, result_retrive, [%{access: url, ocsp_data: ocsp_data, data: certdata}]} =
        DigitalSignatureLib.retrivePKCS7Data(signed_content, get_certs(), true)

      # OCSP (check online) return false, certificate is revoked
      assert {:ok, false} == DigitalSignatureLib.checkCertOnline(certdata, ocsp_data, url)
      refute result_process.is_valid

      # retrive pkcs7 data do not make online and offline check, so is_valid = true
      assert result_retrive.is_valid
    end
  end
end
