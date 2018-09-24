defmodule Core.Api do
  @moduledoc false
  import Ecto.{Query, Changeset}, warn: false
  alias Core.Cert
  alias Core.Crl
  alias Core.Repo
  alias Core.RevokedSN

  # Certificates
  def get_certs do
    query =
      from(
        p in Cert,
        where: p.type in ["root", "tsp"] and p.active,
        left_join: c in Cert,
        on: c.parent == p.id and c.type == "ocsp" and c.active,
        select: {p.type, p.data, c.data}
      )

    query
    |> Repo.all()
  end

  def process_cert({"root", root_cert, ocsp_ert}, %{general: general} = map) do
    new_root = %{root: root_cert, ocsp: ocsp_ert}

    Map.put(map, :general, [new_root | general])
  end

  def process_cert({"tsp", tsp_cert, _}, %{tsp: tsp} = map) do
    Map.put(map, :tsp, [tsp_cert | tsp])
  end

  # CRL: Ursl & Revoked Serial Numbers
  def active_crls do
    Crl
    |> Repo.all()
    |> Enum.map(fn %Crl{url: url} -> url end)
    |> :ordsets.from_list()
  end

  def list_urls do
    Repo.all(Crl)
  end

  def revoked?(url, serialNumber) do
    case get_serial(url, serialNumber) do
      nil -> {:ok, false}
      %RevokedSN{} -> {:ok, true}
    end
  end

  def get_serial(url, serialNumber) do
    Repo.get_by(
      RevokedSN,
      url: url,
      serial_number: Integer.to_string(serialNumber)
    )
  end

  def get_url(url) do
    Repo.get_by(Crl, url: url)
  end

  def write_url(url, nextUpdate) do
    case get_url(url) do
      nil ->
        %Crl{}
        |> crl_changeset(%{url: url, next_update: nextUpdate})
        |> Repo.insert()

      %Crl{} = crl ->
        crl
        |> crl_changeset(%{url: url, next_update: nextUpdate})
        |> Repo.update()
    end
  end

  def write_serials(url, serialNumbers) do
    RevokedSN
    |> where([r], r.url == ^url)
    |> Repo.delete_all()

    serialNumbers
    |> Enum.reduce([], fn number, revoked_sns ->
      [%{url: url, serial_number: Integer.to_string(number)} | revoked_sns]
    end)
    |> chunk_records([])
    |> Enum.each(fn revoked_sns ->
      Repo.insert_all(RevokedSN, revoked_sns, [])
    end)
  end

  @doc """
  Insert n of records m times, because postgres ecto has
  limit of input parameters: 65000
  """
  def chunk_records([], acc), do: acc

  def chunk_records(list, acc) do
    chunk_limit = Confex.fetch_env!(:core, __MODULE__)[:sn_chunk_limit]
    {records, rest} = Enum.split(list, chunk_limit)

    chunk_records(rest, [records | acc])
  end

  def update_serials(url, nextUpdate, serialNumbers) do
    write_url(url, nextUpdate)
    write_serials(url, serialNumbers)
  end

  def crl_changeset(%Crl{} = crl, attrs) do
    crl
    |> cast(attrs, [:url, :next_update])
    |> unique_constraint(:url, name: "crl_url_index")
  end
end
