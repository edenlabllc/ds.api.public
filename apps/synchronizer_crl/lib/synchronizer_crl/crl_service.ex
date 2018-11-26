defmodule SynchronizerCrl.CrlService do
  @moduledoc false
  use GenServer
  require Logger

  alias Core.Api, as: CoreApi
  alias SynchronizerCrl.DateUtils
  use Confex, otp_app: :synchronizer_crl

  # Callbacks

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_info({:update, url}, state) do
    Logger.info("Update #{url}")
    new_state = update_url_state(url, state)
    :erlang.garbage_collect()

    {:noreply, new_state}
  end

  def update_url_state(url, state) do
    clean_timer(url, state)

    with {:ok, next_update} <- update_crl(url),
         {:ok, nt} <- next_update_time(next_update) do
      Logger.info("Next update for #{url} will be in #{nt} milliseconds")
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
    config_urls = :ordsets.from_list(config()[:preload_crl] || [])
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

    with {:CertificateList, tbs_certs, _, _} <- parsed,
         {:revoked, next_update_ts, revoked_certificates} <-
           tbs_revoked_list(tbs_certs),
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

  defp tbs_revoked_list(tbs_certs) do
    with {:TBSCertList, _version, _signature, _issuer, _this_update,
          next_update, revoked_certificates, _crl_extention} <- tbs_certs,
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

  def update_crl(url) do
    with {:ok, %HTTPoison.Response{status_code: 200, body: data}} <-
           HTTPoison.get(url),
         {:ok, data} <- handle_redirect(data),
         {:ok, next_update, serial_numbers} <- parse_crl(data) do
      CoreApi.update_serials(url, next_update, serial_numbers)
      Logger.info("CRL #{url} successfully updated")
      {:ok, next_update}
    else
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:error, url}

      error ->
        retry_timeout = config()[:retry_crl_timeout]

        Logger.info("Error update crl #{url} :: #{inspect(error)}")
        Process.send_after(__MODULE__, {:update, url}, retry_timeout)
        {:error, url}
    end
  end
end
