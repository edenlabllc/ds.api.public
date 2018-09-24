defmodule Core.Certificates do
  @moduledoc false

  alias Core.Api, as: CoreApi
  alias Core.Crl

  # Certificates API
  def get_certificates do
    Enum.reduce(
      CoreApi.get_certs(),
      %{general: [], tsp: []},
      &CoreApi.process_cert(&1, &2)
    )
  end

  # CRL Revoked certificate serial numbers ideintified  url API
  def check_revoked?(url, serial_number) do
    case CoreApi.get_url(url) do
      %Crl{next_update: next_update} ->
        case DateTime.compare(next_update, DateTime.utc_now()) do
          :gt ->
            CoreApi.revoked?(url, serial_number)

          _ ->
            {:error, :outdated}
        end

      _ ->
        {:error, :not_found}
    end
  end

  def revoked(url, serial_number) do
    with {serial_number, ""} <-
           serial_number
           |> String.upcase()
           |> Integer.parse(16) do
      case check_revoked?(url, serial_number) do
        {:ok, _} = response ->
          response

        {:error, reason} ->
          # fil this url for feature requests, with outdated next_update
          CoreApi.write_url(url, Date.add(Date.utc_today(), -1))
          {:error, reason}
      end
    else
      _ -> {:error, {:hex_decode, serial_number}}
    end
  end
end
