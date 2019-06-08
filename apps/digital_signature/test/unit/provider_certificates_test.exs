defmodule DigitalSignatureProviderCertificatesTest do
  @moduledoc """
  test 3rd party services: providers crl
  and next update provide handling
  """
  use ExUnit.Case, async: false
  import DigitalSignatureTestHelper, only: [get_signed_content: 1, get_data: 1]

  alias Core.ProviderCertificates

  describe "read certificate chain from file" do
    @tag :pending

    test "with certificates from file" do
      data = get_data("test/fixtures/signed_le1.json")
      signed_content = get_signed_content(data)

      certs =
        "test/fixtures/acsk-chain.pem"
        |> File.read!()
        |> ProviderCertificates.pem_certificate_chain_data()

      assert %{general: general, tsp: [_ | _]} = certs
      assert [%{root: _data} | _] = general

      assert {:ok, %{is_valid: true},
              [%{serial_number: "33b6cb7bf721b9ce040000004c5a250041875900", ocsp_data: ocsp_data, root_data: root_data}]} =
               DigitalSignatureLib.retrivePKCS7Data(signed_content, certs, true)

      assert String.length(ocsp_data) > 1
      assert String.length(root_data) > 1
    end
  end
end
