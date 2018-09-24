defmodule DigitalSignature.NifServiceAPI do
  @moduledoc """
  API for GenServer NifService
  """
  alias Core.Certificates
  alias DigitalSignature.NifService

  def signed_content(signed_content, signed_data, check, expires_at, timeout) do
    NifService.nif_service_call({:content, signed_content, signed_data, check, expires_at}, timeout)
  end

  def check_online(url, data, ocsp_data, expires_at, timeout) do
    with {:ok, valid?} <- NifService.nif_service_call({:ocsp, url, data, ocsp_data, expires_at}, timeout) do
      {:ok, valid?}
    else
      _ -> {:ok, false}
    end
  end

  defp check_offline(url, serial_number) do
    Certificates.revoked(url, serial_number)
  end

  def provider_cert?(
        certificates_info,
        timeout,
        expires_at
      ) do
    Enum.all?(certificates_info, fn cert_info ->
      %{
        delta_crl: delta_crl,
        serial_number: serial_number,
        crl: crl,
        access: url,
        data: data,
        ocsp_data: ocsp_data,
        root_data: _
      } = cert_info

      with {:ok, false} <- check_offline(crl, serial_number),
           {:ok, false} <- check_offline(delta_crl, serial_number) do
        true
      else
        {:ok, true} ->
          false

        {:error, reason} when reason in ~w(outdated not_found)a ->
          {:ok, valid?} = check_online(url, data, ocsp_data, expires_at, timeout)

          valid?
      end
    end)
  end
end
