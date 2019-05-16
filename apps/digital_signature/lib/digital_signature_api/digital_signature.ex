defmodule DigitalSignature.NifAPI do
  @moduledoc false

  alias DigitalSignature.NifServiceAPI
  alias DigitalSignature.SignedData
  require Logger

  @invalid_content_error_message "Malformed encoded content. Probably, you have encoded corrupted JSON."

  def process_signed_content(signed_content, check) do
    with {:ok, nif_options} <- nif_serice_options(check),
         {:ok, result} <- retrive_signed_data(signed_content, SignedData.new(), nif_options),
         {:ok, content} <- decode_content(result.content) do
      result = Map.put(result, :content, content)
      {:ok, result}
    end
  end

  # Nif

  defp nif_serice_options(check) do
    timeout = Confex.fetch_env!(:digital_signature, :service_call_timeout)
    call_response_threshold = Confex.fetch_env!(:digital_signature, :call_response_threshold)
    expires_at = NaiveDateTime.add(NaiveDateTime.utc_now(), timeout - call_response_threshold, :millisecond)
    {:ok, %{check: check, expires_at: expires_at, timeout: timeout}}
  end

  def retrive_signed_data(signed_content, signed_data, params) do
    %{
      check: check,
      expires_at: expires_at,
      timeout: timeout
    } = params

    with {:ok, nif_responce} <- NifServiceAPI.signed_content(signed_content, signed_data, check, expires_at, timeout) do
      map_signed_data(nif_responce, signed_data, params)
    end
  end

  defp map_signed_data({:ok, data}, _, _), do: {:ok, SignedData.get_map(data)}

  defp map_signed_data({:ok, data, certificates_info}, signed_data, params) do
    valid? = NifServiceAPI.provider_cert?(certificates_info, params[:timeout], params[:expires_at], data[:content])

    if valid? do
      retrive_signed_data(data.content, SignedData.update(signed_data, data), params)
    else
      data = Map.merge(data, %{is_valid: false, validation_error_message: "Certificate verificaton failed"})
      {:ok, signed_data |> SignedData.update(data) |> SignedData.get_map()}
    end
  end

  defp map_signed_data({:error, {:n, n}}, signed_data, _) do
    data =
      signed_data
      |> SignedData.add_sign_error("envelope contains #{n} signatures instead of 1")
      |> SignedData.get_map()

    {:ok, data}
  end

  defp map_signed_data(nif_error, _, _), do: nif_error

  # Decode

  defp decode_content(""), do: {:ok, ""}

  defp decode_content(content) do
    content =
      content
      |> String.replace_leading("\uFEFF", "")
      |> String.replace_trailing(<<0>>, "")

    case Jason.decode(content) do
      {:ok, decoded_content} ->
        {:ok, decoded_content}

      {:error, reason} ->
        Logger.error("Content cannot be decoded from Json, error: #{inspect(reason)}")
        {:error, {:invalid_content, @invalid_content_error_message <> " Error: #{inspect(reason)}", inspect(content)}}
    end
  end
end
