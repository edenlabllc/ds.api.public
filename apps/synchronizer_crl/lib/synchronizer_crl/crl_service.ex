defmodule SynchronizerCrl.CrlService do
  @moduledoc false
  use Confex, otp_app: :synchronizer_crl
  use GenServer
  require Logger
  alias Core.Api, as: CoreApi
  alias Core.Crl
  alias SynchronizerCrl.DateUtils

  def start_link do
    {:ok, pid} = GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
    refresh_certifacates_revoked_list()
    {:ok, pid}
  end

  # Callbacks
  @impl true
  def init(_) do
    {:ok, %{}}
  end

  @impl true
  def handle_info({:update, url}, state) do
    tref = Map.get(state, url)
    if tref, do: Process.cancel_timer(tref)

    new_state =
      case update_crl_resource(url) do
        {:next_update, update_timeout} ->
          add_state_timer_ref(url, update_timeout, state)

        _ ->
          state |> Map.delete(url) |> refresh_state()
      end

    {:noreply, new_state}
  end

  def handle_info({:sync, url}, state) do
    with nil <- Map.get(state, url),
         {:next_update, update_timeout} <- next_sync_crl_resource(url),
         new_state = add_state_timer_ref(url, update_timeout, state) do
      {:noreply, new_state}
    else
      _ -> {:noreply, refresh_state(state)}
    end
  end

  def handle_info(_, state), do: {:noreply, state}

  def add_state_timer_ref(url, update_timeout, state) do
    Logger.info("CRL #{url} will be updated in #{update_timeout} millisecond(s)")
    tref = Process.send_after(__MODULE__, {:update, url}, update_timeout)
    state |> Map.put(url, tref) |> refresh_state
  end

  def next_sync_crl_resource(url) do
    case CoreApi.get_url(url) do
      nil ->
        update_crl_resource(url)

      %Crl{next_update: next_update} ->
        {:ok, update_timeout} = DateUtils.next_update_time(next_update, true)
        {:next_update, update_timeout}
    end
  end

  def update_crl_resource(url) do
    retry_timeout = config()[:retry_crl_timeout]

    with {:ok, next_update, serial_numbers} <- get_provider_crl(url),
         :ok <- CoreApi.update_serials(url, next_update, serial_numbers),
         {:ok, update_timeout} <- DateUtils.next_update_time(next_update) do
      {:next_update, update_timeout}
    else
      {:error, :outdated} ->
        CoreApi.remove_url(url)
        :halt

      _ ->
        {:next_update, retry_timeout}
    end
  end

  def get_provider_crl(url) do
    with {:ok, %HTTPoison.Response{status_code: 200, body: data}} <- HTTPoison.get(url),
         {:ok, data} <- handle_redirect(data),
         {:ok, next_update, serial_numbers} <- parse_crl(data) do
      {:ok, next_update, serial_numbers}
    else
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        Logger.error("CRL file #{url}: not found")
        {:error, :outdated}

      error ->
        Logger.error("Failed to get provider #{url}: #{inspect(error)}")
        :cont
    end
  end

  def refresh_certifacates_revoked_list do
    config_urls = config()[:preload_crl] || []
    active_crls = CoreApi.active_crls()
    crls = config_urls ++ active_crls

    crls
    |> MapSet.new()
    |> MapSet.to_list()
    |> Enum.each(fn url ->
      send(__MODULE__, {:sync, url})
    end)
  end

  def parse_crl(data) do
    parsed =
      try do
        :public_key.der_decode(:CertificateList, data)
      catch
        _error, _reason ->
          {:error, :decode}
      end

    garbage_collect()

    with {:CertificateList, tbs_certs, _, _} <- parsed,
         {:revoked, next_update_ts, revoked_certificates} <- tbs_revoked_list(tbs_certs),
         {:ok, next_update} <- DateUtils.convert_date(next_update_ts) do
      revoked_serial_numbers =
        Enum.reduce(
          revoked_certificates,
          [],
          fn {:TBSCertList_revokedCertificates_SEQOF, user_certificate, _, _}, serial_numbers ->
            [user_certificate | serial_numbers]
          end
        )

      {:ok, next_update, revoked_serial_numbers}
    end
  end

  defp tbs_revoked_list(tbs_certs) do
    with {:TBSCertList, _version, _signature, _issuer, _this_update, next_update, revoked_certificates, _crl_extention} <-
           tbs_certs,
         {:utcTime, next_update_ts} <- next_update,
         {:revoked_list, true} <- {:revoked_list, is_list(revoked_certificates)} do
      {:revoked, next_update_ts, revoked_certificates}
    else
      err ->
        Logger.error("Provider errored crl: #{inspect(err)}")
        {:error, err}
    end
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

  defp get_redirect_headers(%{document_cookie: document_cookie}),
    do: [{"Cookie", document_cookie}]

  defp get_redirect_headers(_), do: []

  defp redirect(%{location_href: location_href} = params, _) do
    case HTTPoison.get(location_href, get_redirect_headers(params)) do
      {:ok, %HTTPoison.Response{status_code: 200, body: data}} -> {:ok, data}
      error -> error
    end
  end

  defp redirect(_, data), do: {:ok, data}

  defp handle_redirect(data) do
    redirect_script =
      try do
        Floki.find(data, "script")
      rescue
        _ -> nil
      end

    case redirect_script do
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

  def garbage_collect() do
    :erlang.garbage_collect()
  end

  def refresh_state(state) do
    :erlang.garbage_collect()
    state
  end
end
