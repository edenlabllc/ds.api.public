defmodule DigitalSignature.NifServiceAPI do
  @moduledoc """
  API for GenServer NifService
  """
  alias DigitalSignature.NifService
  require Logger

  @kafka_producer Application.get_env(:digital_signature, :kafka)[:producer]
  @timeout 5000
  @rpc_worker Application.get_env(:ds_api, :rpc_worker)

  def signed_content(signed_content, signed_data, check, expires_at, timeout) do
    NifService.nif_service_call({:content, signed_content, signed_data, check, expires_at}, timeout)
  end

  def signatures_valid_online?(signatures) do
    expires_at = NaiveDateTime.add(NaiveDateTime.utc_now(), @timeout, :millisecond)

    Enum.all?(signatures, fn %{access: url, data: data, ocsp_data: ocsp_data} ->
      {:ok, true} == check_online(url, data, ocsp_data, expires_at, @timeout)
    end)
  end

  def check_online(url, data, ocsp_data, expires_at, timeout) do
    case NifService.nif_service_call({:ocsp, url, data, ocsp_data, expires_at}, timeout) do
      {:ok, true} ->
        Logger.warn("Online check success")
        {:ok, true}

      {:ok, false, validation_error} ->
        Logger.warn("Invalid signature(s): OSCP provider response #{validation_error}")
        {:ok, false}

      error ->
        Logger.warn("Unable to call provider: #{inspect(error)}")
        {:ok, false}
    end
  end

  defp check_revoked(crl, serial_number) do
    @rpc_worker.run("synchronizer_crl", SynchronizerCrl.Rpc, :check_revoked, [crl, serial_number])
  end

  def provider_cert?(certificates_info, timeout, expires_at, content) do
    Enum.all?(certificates_info, fn cert_info ->
      %{
        crl: crl,
        delta_crl: delta_crl,
        serial_number: serial_number,
        access: url,
        data: data,
        ocsp_data: ocsp_data,
        root_data: _
      } = cert_info

      with {:ok, false} <- check_revoked(crl, serial_number),
           {:ok, false} <- check_revoked(delta_crl, serial_number) do
        :ok = push_signed_content(%{signatures: certificates_info, content: content})
        Logger.warn("Success offline check")
        true
      else
        {:ok, true} ->
          Logger.warn("Invalid signature(s): CRL offline check")
          false

        {:error, reason} when reason in ~w(outdated not_found)a ->
          Logger.warn("No crl found for #{crl}, #{delta_crl}")
          {:ok, valid?} = check_online(url, data, ocsp_data, expires_at, timeout)
          valid?
      end
    end)
  end

  defp push_signed_content(data) do
    case @kafka_producer.publish_sigantures(data) do
      :ok ->
        :ok

      error ->
        Logger.error("kafka producer fails: #{inspect(error)}")
        {:error, :kafka_error}
    end
  end
end
