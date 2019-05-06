defmodule SynchronizerCrl.Provider do
  @moduledoc false

  alias SynchronizerCrl.DateUtils

  def get_revoked_certificates(url) do
    with :ok <- validate_authority(url),
         {:ok, response} <- HTTPoison.get(url),
         {:ok, provider_data} <- validate_data(response),
         {:ok, data} <- handle_redirect(provider_data),
         {:CertificateList, tbs_certs, _, _} <- parse(data),
         {:TBSCertList, _, _, _, _, {:utcTime, ts}, certs, _} <- tbs_certs,
         true <- is_list(certs),
         {:ok, next_update} <- DateUtils.convert_date(ts) do
      serial_numbers = Enum.map(certs, fn {:TBSCertList_revokedCertificates_SEQOF, sn, _, _} -> sn end)
      :erlang.garbage_collect()
      {:ok, next_update, serial_numbers}
    end
  end

  defp validate_authority(url) do
    if URI.parse(url).authority, do: :ok
  end

  defp parse(data) do
    :public_key.der_decode(:CertificateList, data)
  rescue
    _ -> :error
  end

  defp validate_data(%HTTPoison.Response{status_code: 200, body: data}), do: {:ok, data}
  defp validate_data(%HTTPoison.Response{status_code: 404}), do: :outdated
  defp validate_data(_), do: :error

  defp handle_redirect(data) do
    case redirect_script(data) do
      [{"script", _, [script]}] ->
        script
        |> String.split(";")
        |> Enum.reduce(%{}, fn line, acc ->
          line |> process_script_line() |> Map.merge(acc)
        end)
        |> redirect(data)

      _ ->
        {:ok, data}
    end
  end

  defp redirect_script(data) do
    Floki.find(data, "script")
  rescue
    _ -> nil
  end

  defp parse_script_line_value(line) do
    case Code.format_string!(line) do
      ["document", ".", "cookie", " =", " ", "\"", value, "\""] ->
        %{document_cookie: value}

      ["location", ".", "href", " =", " ", "\"", value, "\""] ->
        %{location_href: value}

      _ ->
        %{}
    end
  end

  defp process_script_line(line) do
    case Code.string_to_quoted(line) do
      {:ok, _} -> parse_script_line_value(line)
      {:error, _} -> %{}
    end
  end

  defp get_redirect_headers(%{document_cookie: document_cookie}), do: [{"Cookie", document_cookie}]
  defp get_redirect_headers(_), do: []

  defp redirect(%{location_href: location_href} = params, _) do
    case HTTPoison.get(location_href, get_redirect_headers(params)) do
      {:ok, %HTTPoison.Response{status_code: 200, body: data}} -> {:ok, data}
      error -> error
    end
  end

  defp redirect(_, data), do: {:ok, data}
end
