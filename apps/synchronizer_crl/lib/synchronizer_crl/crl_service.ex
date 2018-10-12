defmodule SynchronizerCrl.CrlService do
  @moduledoc false
  use GenServer
  require Logger

  alias Core.Api, as: CoreApi
  alias SynchronizerCrl.DateUtils

  # Callbacks

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_info({:update, url}, state) do
    new_state = update_url_state(url, state)
    :erlang.garbage_collect()

    {:noreply, new_state}
  end

  def update_url_state(url, state) do
    clean_timer(url, state)

    with {:ok, next_update} <- update_crl(url),
         {:ok, nt} <- next_update_time(next_update) do
      tref = Process.send_after(__MODULE__, {:update, url}, nt)
      Map.put(state, url, tref)
    else
      _ -> state
    end
  end

  def start_link do
    {:ok, pid} = GenServer.start_link(__MODULE__, %{}, name: __MODULE__)

    Enum.each(crl_urls(), fn url ->
      send(__MODULE__, {:update, url})
    end)

    {:ok, pid}
  end

  def crl_urls do
    config_urls =
      :ordsets.from_list(
        Confex.fetch_env!(:synchronizer_crl, __MODULE__)[:preload_crl] || []
      )

    active_crls = CoreApi.active_crls()

    :ordsets.union([config_urls, active_crls])
  end

  def clean_timer(url, state) do
    case state do
      %{^url => nil} -> :ok
      %{^url => tref} -> Process.cancel_timer(tref)
      _ -> :ok
    end
  end

  def next_update_time(next_update) do
    case DateTime.diff(next_update, DateTime.utc_now(), :millisecond) do
      n when n >= 0 ->
        {:ok, n}

      n when n > -1000 * 60 * 60 * 12 ->
        # crl file shoul be updated less then 12 hours ago, but
        # providers offen has little bit outdated crl files
        # let's check this url in 30 minutes
        {:ok, 30 * 60 * 60 * 1000}

      _ ->
        # Suspicious crl file, probaply this url never be updated, skip it
        {:error, :outdated}
    end
  end

  def parse_crl(data) do
    parsed =
      try do
        :public_key.der_decode(:CertificateList, data)
      catch
        _error, _reason ->
          {:error, :decode}
      end

    with {:CertificateList,
          {:TBSCertList, _, _, _, _, {:utcTime, next_update_ts},
           revoked_certificates, _}, _, _} <- parsed,
         true <- is_list(revoked_certificates),
         {:ok, next_update} <- DateUtils.convert_date(next_update_ts) do
      revoked_serial_numbers =
        Enum.reduce(
          revoked_certificates,
          [],
          fn {:TBSCertList_revokedCertificates_SEQOF, user_certificate, _, _},
             serial_numbers ->
            [user_certificate | serial_numbers]
          end
        )

      {:ok, next_update, revoked_serial_numbers}
    end
  end

  def update_crl(url) do
    with {:ok, %HTTPoison.Response{status_code: 200, body: data}} <-
           HTTPoison.get(url),
         {:ok, next_update, serial_numbers} <- parse_crl(data) do
      CoreApi.update_serials(url, next_update, serial_numbers)
      Logger.info("CRL #{url} successfully updated")
      {:ok, next_update}
    else
      error ->
        retry_timeout =
          Confex.fetch_env!(:synchronizer_crl, __MODULE__)[:retry_crl_timeout]

        Logger.info("Error update crl #{url} :: #{inspect(error)}")
        Process.send_after(__MODULE__, {:update, url}, retry_timeout)
        {:error, url}
    end
  end
end
