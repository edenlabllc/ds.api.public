defmodule DS.SynchronizerCrl.Rpc do
  @moduledoc false
  alias Core.CRLs
  alias SynchronizerCrl.Worker
  @type crl :: binary

  @doc """
  Synchronize with crl

  Available parameters:

  | Parameter          | Type             | Example                                              | Description                                        |
  | :----------------: | :--------------: | :--------------------------------------------------: | :------------------------------------------------: |
  | crl         | `binary`         | "http://uakey.com.ua/list-delta.crl"

  Returns crl after send crl for synchronization to SrlService | nil if crl is not url

  ## Examples

      iex> MPI.Rpc.synchronize_certificate_revoked_list("http://uakey.com.ua/list-delta.crl")
      :ok
      iex> MPI.Rpc.synchronize_certificate_revoked_list(1)
      nil
  """

  def synchronize_certificate_revoked_list(crl) when is_binary(crl) do
    unless CRLs.get_by_url(crl), do: Worker.update_crl_resource(crl)
  end

  def synchronize_certificate_revoked_list(_), do: nil
end
