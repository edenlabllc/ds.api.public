defmodule DigitalSignatureCheckOCSPLibTest do
  @moduledoc """
  OCSP check only, check in single nif call(process pkcs7data) and
  check in another proccess (retrive pkcs7data and check cert online)
  Summury main test for nifs
  test checkCertOnline c nif, retrive and process PKCS7Data
  """
  import DigitalSignatureTestHelper
  use ExUnit.Case, async: false

  alias DigitalSignature.NifService
  alias DigitalSignature.NifServiceAPI

  describe "With/Without ocsp certificate no segfault" do
    @tag :pending
    test "OCSP exists and return ocsp_data in checklist" do
      data = get_data("../digital_signature/test/fixtures/altersign.json")
      signed_content = get_signed_content(data)
      assert {:ok, result, signatures} = DigitalSignatureLib.retrivePKCS7Data(signed_content, get_certs(), true)
      assert result[:is_valid]
      assert String.length(hd(signatures)[:ocsp_data]) > 0
      assert NifServiceAPI.signatures_valid_online?(signatures)
    end

    @tag :pending
    test "without ocsp cert in db does not return ocsp_data in checklist" do
      data = get_data("../digital_signature/test/fixtures/altersign.json")
      signed_content = get_signed_content(data)
      certs = get_certs()
      general = Enum.map(certs[:general], fn %{root: root} -> %{root: root, ocsp: nil} end)
      certs = %{certs | general: general}

      assert {:ok, result, signatures} =
               DigitalSignatureLib.retrivePKCS7Data(
                 signed_content,
                 certs,
                 true
               )

      assert result[:is_valid]
      assert String.length(hd(signatures)[:ocsp_data]) == 0
      assert NifServiceAPI.signatures_valid_online?(signatures)
    end
  end

  describe "Must process all data correctly online" do
    test "can process signed legal entity" do
      data = get_data("../digital_signature/test/fixtures/signed_le1.json")
      signed_content = get_signed_content(data)
      certs = get_certs()

      {:ok, _, [%{access: url, ocsp_data: ocsp_data, data: certdata}]} =
        DigitalSignatureLib.retrivePKCS7Data(signed_content, get_certs(), true)

      assert {:ok, true} == NifService.ocsp_reduce_while_match(url, certdata, ocsp_data, certs.ocsp)
    end

    @tag :pending
    test "can process signed legal entity 25 times in a row" do
      data = get_data("../digital_signature/test/fixtures/signed_le1.json")
      signed_content = get_signed_content(data)
      certs = get_certs()

      Enum.each(1..25, fn _ ->
        {:ok, _, [%{access: url, ocsp_data: ocsp_data, data: certdata}]} =
          DigitalSignatureLib.retrivePKCS7Data(signed_content, certs, true)

        assert {:ok, true} == NifService.ocsp_reduce_while_match(url, certdata, ocsp_data, certs.ocsp)
      end)
    end

    test "can process second signed legal entity" do
      data = get_data("../digital_signature/test/fixtures/signed_le2.json")
      signed_content = get_signed_content(data)
      certs = get_certs()

      {:ok, _, [%{access: url, ocsp_data: ocsp_data, data: certdata}]} =
        DigitalSignatureLib.retrivePKCS7Data(signed_content, certs, true)

      assert {:ok, true} == NifService.ocsp_reduce_while_match(url, certdata, ocsp_data, certs.ocsp)
    end

    test "can validate data signed with valid Privat personal key" do
      data = File.read!("../digital_signature/test/fixtures/hello.txt.sig")
      certs = get_certs()

      {:ok, result_retrive, [%{access: url, ocsp_data: ocsp_data, data: data}]} =
        DigitalSignatureLib.retrivePKCS7Data(data, certs, true)

      assert {:ok, true} == NifService.ocsp_reduce_while_match(url, data, ocsp_data, certs.ocsp)
      assert result_retrive.is_valid
    end
  end

  describe "test revoked certificate online ocsp" do
    test "processing signed with revoked Privat personal key" do
      data = get_data("../digital_signature/test/fixtures/hello_revoked.json")
      {:ok, signed_content} = Base.decode64(Map.get(data, "signed_content"))
      certs = get_certs()

      {:ok, result_retrive, [%{access: url, ocsp_data: ocsp_data, data: certdata}]} =
        DigitalSignatureLib.retrivePKCS7Data(signed_content, certs, true)

      # OCSP (check online) return false, certificate is revoked
      assert {:ok, false, "OCSP: Certificate status error"} ==
               NifService.ocsp_reduce_while_match(url, certdata, ocsp_data, certs.ocsp)

      # retrive pkcs7 data do not make online and offline check, so is_valid = true
      assert result_retrive.is_valid
    end
  end
end
