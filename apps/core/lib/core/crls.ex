defmodule Core.CRLs do
  @moduledoc false
  import Ecto.{Query, Changeset}, warn: false
  alias Core.CRL
  alias Core.Repo

  def active_crls do
    Repo.all(CRL)
  end

  def get_by_url(url) do
    CRL
    |> where([c], c.url == ^url)
    |> Repo.one()
  end

  def store(url, nextUpdate) do
    %CRL{}
    |> cast(%{url: url, next_update: nextUpdate}, [:url, :next_update])
    |> Repo.insert(on_conflict: :replace_all, conflict_target: :url)
  end

  def remove(url) do
    with %CRL{} = crl <-
           CRL
           |> where([c], c.url == ^url)
           |> Repo.one() do
      Repo.delete(crl)
    end
  end

  def get_urls_for_update do
    CRL
    |> where([c], c.next_update < ^DateTime.utc_now())
    |> Repo.all()
  end
end
