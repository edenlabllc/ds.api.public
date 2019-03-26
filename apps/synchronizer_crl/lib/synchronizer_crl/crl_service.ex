defmodule SynchronizerCrl.CrlService do
  @moduledoc false
  use Confex, otp_app: :synchronizer_crl
  use GenServer
  require Logger
  alias Core.Api, as: CoreApi
  alias Core.Crl
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
    if is_reference(state[url]), do: Process.cancel_timer(state[url])
    garbage_collect()
    {:noreply, update_crl_resource(url, state)}
  end

  def handle_info(_, state), do: {:noreply, state}

  def update_crl_resource(url, state) do
    url
    |> CoreApi.get_crl()
    |> next_crl_update(url)
    |> process_state_update(url, state)
  end

  defp process_state_update(:outdated, url, state) do
    CoreApi.remove_crl(url)
    state
  end

  defp process_state_update({:next_update, timeout}, url, state) do
    Logger.info("CRL #{url} will be updated in #{timeout} millisecond(s)")
    crl_timer = Process.send_after(__MODULE__, {:synchronize, url}, timeout)
    Map.put(state, url, crl_timer)
  end

  defp next_crl_update(%Crl{next_update: next_update}, _), do: DateUtils.next_update_time(next_update, true)

  defp next_crl_update(nil, url) do
    with {:ok, next_update, serial_numbers} <- Provider.get_revoked_certificates(url),
         {:ok, _} <- CoreApi.update_serials(url, next_update, serial_numbers),
         {:ok, update_timeout} <- DateUtils.next_update_time(next_update) do
      {:next_update, update_timeout}
    else
      {:error, :outdated} -> :outdated
      _ -> {:next_update, config()[:retry_crl_timeout]}
    end
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

  def garbage_collect, do: :erlang.garbage_collect()
end
