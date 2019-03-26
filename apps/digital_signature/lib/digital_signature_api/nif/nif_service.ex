defmodule DigitalSignature.NifService do
  @moduledoc """
  Gen server provides nif synchronious calls, because
  nif executing time is to hight for parralel calls
  """
  use GenServer
  alias Core.Certificates

  require Logger

  # Callbacks
  def init(certs_cache_ttl) do
    certs = Certificates.get_certificates()
    Process.send_after(self(), :refresh, certs_cache_ttl)
    {:ok, {certs_cache_ttl, certs}}
  end

  @doc """
  RFC2650: implementation OCSP with nifs
  """
  def handle_call({:ocsp, url, data, ocsp_data, expires_at}, _from, state) do
    processing_result =
      with :ok <- check_time(expires_at),
           {:ok, valid?} <- DigitalSignatureLib.checkCertOnline(data, ocsp_data, url) do
        valid?
      end

    {:reply, processing_result, state}
  end

  @doc """
  Get signed content with nifs
  """
  def handle_call({:content, signed_content, signed_data, check, expires_at}, _, {_, certs} = state) do
    processing_result =
      with :ok <- check_time(expires_at) do
        get_signed_content(signed_content, signed_data, certs, check)
      end

    {:reply, processing_result, state}
  end

  def handle_call(_, _from, state), do: {:reply, :not_implemented, state}

  def handle_info(:refresh, {certs_cache_ttl, _certs}) do
    certs = Certificates.get_certificates()
    # GC
    :erlang.garbage_collect(self())

    Process.send_after(self(), :refresh, certs_cache_ttl)
    {:noreply, {certs_cache_ttl, certs}}
  end

  # Handle unexpected messages
  def handle_info(unexpected_message, certs) do
    super(unexpected_message, certs)
  end

  def start_link(certs_cache_ttl) do
    GenServer.start_link(__MODULE__, certs_cache_ttl, name: __MODULE__)
  end

  # Client

  @doc """
  Catch error in case message expired or gen server internal error
  """
  def nif_service_call(requets, timeout) do
    nif_responce = GenServer.call(__MODULE__, requets, timeout)
    {:ok, nif_responce}
  catch
    :exit, {:timeout, error} ->
      {:error, {:nif_service_timeout, error}}

    what, why ->
      Logger.error("Could not get gen_server #{__MODULE__} call: #{inspect(what)} :: #{inspect(why)}")

      {:error, :unavailable}
  end

  #  internal Nif service
  defp check_time(expires_at) do
    if NaiveDateTime.compare(expires_at, NaiveDateTime.utc_now()) == :gt do
      :ok
    else
      Logger.info("NifService message queue timeout")
      {:error, {:nif_service_timeout, "messaqe queue timeout"}}
    end
  end

  defp get_signed_content(signed_content, signed_data, certs, check) do
    case DigitalSignatureLib.checkPKCS7Data(signed_content) do
      {:ok, 1} ->
        DigitalSignatureLib.retrivePKCS7Data(signed_content, certs, check)

      {:ok, n} ->
        {:error, {:n, n}}

      {:error, :signed_data_load} ->
        {:ok, signed_data}
    end
  end
end
