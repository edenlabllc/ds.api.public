defmodule SynchronizerCrl.CrlService do
  @moduledoc false
  use Confex, otp_app: :synchronizer_crl
  use GenServer
  require Logger
  alias Core.Api, as: CoreApi
  alias SynchronizerCrl.DateUtils
  alias SynchronizerCrl.Provider

  def synchronize_certificate_revoked_list(provider_url), do: send(__MODULE__, {:synchronize, provider_url})

  def start_link do
    __MODULE__
    |> GenServer.start_link(%{}, name: __MODULE__)
    |> refresh_certifacates_revoked_list()
  end

  # Callbacks
  @impl true
  def init(_), do: {:ok, %{}}

  @impl true
  def handle_info({:synchronize, url}, state) do
    if is_reference(state[url]) do
      timeout = :erlang.read_timer(state[url])

      if timeout do
        Logger.info("CRL #{url} already in state")
        {:noreply, state}
      else
        :erlang.cancel_timer(state[url])
        new_state = Map.put(state, url, update_crl_resource(url))
        {:noreply, new_state}
      end
    else
      new_state = Map.put(state, url, update_crl_resource(url))
      {:noreply, new_state}
    end
  end

  def handle_info(_, state), do: {:noreply, state}

  def update_crl_resource(url) do
    marker =
      with {:ok, next_update, serial_numbers} <- Provider.get_revoked_certificates(url),
           {:ok, _} <- CoreApi.update_serials(url, next_update, serial_numbers),
           {:ok, timeout} <- DateUtils.next_update_time(next_update) do
        Logger.info("CRL #{url} will be updated in #{timeout} millisecond(s)")
        sync_reference(url, timeout)
      else
        {:error, :outdated} ->
          Logger.info("CRL #{url} is outdated")
          CoreApi.remove_crl(url)
          nil

        error ->
          timeout = config()[:retry_crl_timeout]
          Logger.warn("Error #{inspect(error)} for #{url} on update, retry in #{timeout}")
          sync_reference(url, timeout)
      end

    garbage_collect()
    marker
  end

  defp refresh_certifacates_revoked_list({:ok, pid}) do
    config_urls = config()[:preload_crl] || []
    active_crls = CoreApi.active_crls()
    crls = config_urls ++ active_crls

    crls
    |> MapSet.new()
    |> MapSet.to_list()
    |> Enum.each(&synchronize_certificate_revoked_list(&1))

    garbage_collect()
    {:ok, pid}
  end

  defp refresh_certifacates_revoked_list(_), do: :error

  defp sync_reference(url, timeout), do: Process.send_after(__MODULE__, {:synchronize, url}, timeout)
  def garbage_collect, do: :erlang.garbage_collect()
end
