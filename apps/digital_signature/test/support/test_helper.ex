defmodule DigitalSignatureTestHelper do
  @moduledoc """
  common test functions
  """
  alias Core.Cert
  alias Core.Certificates
  alias Core.Repo

  def atomize_keys(map) do
    map
    |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end)
    |> Enum.into(%{})
  end

  def decode_content(result) do
    Jason.decode!(result.content)
  end

  def get_data(json_file) do
    file = File.read!(json_file)
    json = Jason.decode!(file)

    json["data"]
  end

  def get_signed_content(data) do
    data["signed_content"]
    |> Base.decode64!()
  end

  def get_certs do
    files = ["../digital_signature/test/fixtures/acsk-chain.pem", "../digital_signature/test/fixtures/privat-chain.pem"]

    %{general: general, tsp: tsp} =
      Enum.reduce(files, %{general: [], tsp: []}, fn pem, acc ->
        %{general: general, tsp: tsp} = pem |> File.read!() |> Core.ProviderCertificates.pem_certificate_chain_data()
        %{general: acc.general ++ general, tsp: acc.tsp ++ tsp}
      end)

    partial_general = [
      %{
        root: File.read!("../digital_signature/test/fixtures/CA-Altersign-2018.cer"),
        ocsp: File.read!("../digital_signature/test/fixtures/OCSP-Altersign-2017.cer")
      }
    ]

    partial_tsp = [File.read!("../digital_signature/test/fixtures/TSP-Altersign-2018.cer")]
    general = partial_general ++ general
    tsp = tsp ++ partial_tsp
    ocsp_extended = general |> Enum.map(& &1[:ocsp]) |> Certificates.group_ocsp_certificate_by_organization()

    %{general: general, tsp: tsp, ocsp: ocsp_extended}
  end

  def insert_certs do
    files = ["../digital_signature/test/fixtures/acsk-chain.pem", "../digital_signature/test/fixtures/privat-chain.pem"]

    Enum.each(files, fn file ->
      pem = File.read!(file)

      Repo.insert!(%Cert{
        name: file,
        data: pem,
        parent: nil,
        type: "pem",
        active: true
      })
    end)

    %{id: altersign_root_id} =
      Repo.insert!(%Cert{
        name: "Altersign",
        data: File.read!("../digital_signature/test/fixtures/CA-Altersign-2018.cer"),
        parent: nil,
        type: "root",
        active: true
      })

    Repo.insert!(%Cert{
      name: "Altersign",
      data: File.read!("../digital_signature/test/fixtures/OCSP-Altersign-2018.cer"),
      parent: altersign_root_id,
      type: "ocsp",
      active: true
    })
  end

  def reload_state do
    Supervisor.terminate_child(
      DigitalSignature.Supervisor,
      DigitalSignature.NifService
    )

    DigitalSignatureTestHelper.insert_certs()

    {:ok, _} =
      Supervisor.restart_child(
        DigitalSignature.Supervisor,
        DigitalSignature.NifService
      )
  end
end
