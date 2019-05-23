defmodule SynchronizerCrl.RevokedSerialNumbers do
  @moduledoc """
  store revoked numbers for app in persistent_term
  """
  alias Core.CRLs
  require Logger

  def store(url, next_update, serial_numbers) do
    # the fastest way to get number
    revoked_serial_numbers_map =
      Enum.reduce(serial_numbers, %{}, fn number, revoked -> Map.put(revoked, Integer.to_string(number), nil) end)

    :persistent_term.put(url, %{next_update: next_update, sns: revoked_serial_numbers_map})
    :ok
  end

  def check_revoked(url, number) do
    with {:ok, serial_number} <- parse_serial(number),
         %{next_update: next_update, sns: sns} <- :persistent_term.get(url, :not_found),
         :valid <- next_update_valid(next_update),
         {:ok, is_revoked?} <- revoked?(sns, serial_number) do
      Logger.warn("Check revoked #{number} for #{url}: #{is_revoked?}")
      {:ok, is_revoked?}
    else
      :not_found ->
        # store url, and worker will synchronize this url later
        Logger.warn("Store url #{url} for syncs")
        unless CRLs.get_by_url(url), do: CRLs.store(url, DateTime.utc_now())
        {:error, :not_found}

      error ->
        Logger.warn("Error on get #{number} for #{url}, #{inspect(error)}")
        {:error, error}
    end
  end

  def delete(url) do
    :persistent_term.erase(url)
  end

  defp parse_serial(number) do
    with {serial_number, ""} <- number |> String.upcase() |> Integer.parse(16) do
      {:ok, serial_number}
    else
      _ -> {:hex_decode, number}
    end
  end

  defp next_update_valid(next_update) do
    case DateTime.compare(next_update, DateTime.utc_now()) do
      :gt -> :valid
      _ -> :outdated
    end
  end

  defp revoked?(sns, serial_number) do
    if Map.has_key?(sns, serial_number), do: {:ok, true}, else: {:ok, false}
  end
end
