defmodule SynchronizerCrl.Worker do
  @moduledoc false
  use Confex, otp_app: :synchronizer_crl
  use GenServer
  require Logger

  alias Core.CRL
  alias Core.CRLs
  alias SynchronizerCrl.RevokedSerialNumbers
  alias SynchronizerCrl.DateUtils
  alias SynchronizerCrl.Provider

  def start_link do
    __MODULE__
    |> GenServer.start_link(%{}, name: __MODULE__)
    |> start()
  end

  # Callbacks
  @impl true
  def init(_), do: {:ok, %{}}

  @impl true
  def handle_info(:start, state) do
    synchronize_crl(CRLs.active_crls())
    ref = Process.send_after(self(), :sync, config()[:resync_timeout])
    garbage_collect()
    {:noreply, %{ref: ref}}
  end

  def handle_info(:sync, state) do
    if is_reference(state[:ref]), do: Process.cancel_timer(state[:ref])
    synchronize_crl(CRLs.get_urls_for_update())
    ref = Process.send_after(self(), :sync, config()[:resync_timeout])
    garbage_collect()
    {:noreply, %{ref: ref}}
  end

  def update_crl_resource(url) do
    Logger.warn("Update #{url}")

    with {:ok, next_update, serial_numbers} <- Provider.get_revoked_certificates(url),
         {:ok, _timeout} <- DateUtils.next_update_time(next_update),
         :ok <- RevokedSerialNumbers.store(url, next_update, serial_numbers),
         {:ok, _} <- CRLs.store(url, next_update) do
      Logger.warn("CRL #{url} successfully updated")
    else
      error ->
        Logger.warn("CRL #{url} can't be updated, got: #{inspect(error)}")
        CRLs.remove(url)
    end

    garbage_collect()
  end

  def garbage_collect, do: :erlang.garbage_collect()

  defp start({:ok, pid}) do
    if config()[:sync], do: send(pid, :start)
    {:ok, pid}
  end

  defp synchronize_crl([]), do: :ok

  defp synchronize_crl([%CRL{url: url} | urls]) do
    update_crl_resource(url)
    synchronize_crl(urls)
  end
end
