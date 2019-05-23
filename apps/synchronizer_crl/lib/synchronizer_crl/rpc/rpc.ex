defmodule SynchronizerCrl.Rpc do
  @moduledoc false

  alias SynchronizerCrl.RevokedSerialNumbers
  require Logger

  @doc """
  Check serial number is revoked

  Available parameters:

  | Parameter          | Type             | Example                                              | Description                                        |
  | :----------------: | :--------------: | :--------------------------------------------------: | :------------------------------------------------: |
  | crl         | `binary`         | "http://uakey.com.ua/list-delta.crl" |
  | sn          | `binary`         | "302300406797054607102198254237226643374679000320"

  Returns crl after send crl for synchronization to SrlService | nil if crl is not url

  ## Examples

      iex> SynchronizerCrl.Rpc.check_revoked("http://uakey.com.ua/list-delta.crl")
      :ok
      iex> SynchronizerCrl.Rpc.check_revoked(1)
      {:error, :bad_args}
  """

  @spec check_revoked(crl :: binary(), serial_number :: binary()) ::
          {:ok, boolean()} | {:error, :bad_args} | {:error, :not_found} | {:error, term()}

  def check_revoked(crl, serial_number) when is_binary(crl) and is_binary(serial_number) do
    RevokedSerialNumbers.check_revoked(crl, serial_number)
  end

  def check_revoked(crl, serial_number) do
    Logger.warn("Both arguments should be binary, args: #{inspect(crl)}, #{inspect(serial_number)}")
    {:error, :bad_args}
  end
end
