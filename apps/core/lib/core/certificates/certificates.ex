defmodule Core.Certificates do
  @moduledoc false

  import Ecto.Query
  import Ecto.Changeset
  alias Core.Cert
  alias Core.ProviderCertificates
  alias Core.Repo
  alias Ecto.UUID

  # Certificates API
  def get_certificates do
    make_pem_certificate_chain()

    %{general: general, tsp: tsp} =
      Enum.reduce(
        get_certs(),
        %{general: [], tsp: []},
        &process_cert(&1, &2)
      )

    ocsp_extended = general |> Enum.map(& &1[:ocsp]) |> group_ocsp_certificate_by_organization()
    %{general: general, tsp: tsp, ocsp: ocsp_extended}
  end

  defp process_cert(["root", root_cert, ocsp_ert], %{general: general} = map) do
    Map.put(map, :general, [%{root: root_cert, ocsp: ocsp_ert} | general])
  end

  defp process_cert(["tsp", tsp_cert, _], %{tsp: tsp} = map) do
    Map.put(map, :tsp, [tsp_cert | tsp])
  end

  @doc """
  Form chain from pem and rewrite with actual subject if exists in one transaction, and deactivate pem - to avoid parsing each time on certificate reload
  """
  def make_pem_certificate_chain do
    "pem"
    |> get_certificates_by_type()
    |> Enum.reduce(0, fn %Cert{data: data} = certificate, count ->
      %{general: general, tsp: tsp} = ProviderCertificates.pem_extended_chain(data)

      # We rewrite ganaral certificates to ensure all root-ocsp pairs formed correctly
      Enum.each(general, fn %{root: root, ocsp: ocsp} ->
        root.subject
        root = Map.merge(root, %{id: UUID.generate(), active: true})
        ocsp = ocsp |> Map.put(:parent, root[:id]) |> Map.merge(%{id: UUID.generate(), active: true})
        Enum.each([root, ocsp], &process_matches_db_certificate(&1))
      end)

      # Refresh tsp certificates topics
      Enum.each(tsp, fn data ->
        {tsp, from, to} = ProviderCertificates.decode_certificate_entry(data)
        tsp = ProviderCertificates.form_key_info(tsp, data, from, to)
        process_matches_db_certificate(Map.merge(tsp, %{id: UUID.generate(), active: true}))
      end)

      deactivate_certificate(certificate)
      count + 1
    end)
  end

  def group_ocsp_certificate_by_organization(chain) do
    chain =
      Enum.reduce(chain, [], fn
        nil, acc ->
          acc

        data, acc ->
          {crt, from, to} = ProviderCertificates.decode_certificate_entry(data)
          info = ProviderCertificates.form_key_info(crt, data, from, to)
          [info | acc]
      end)

    Enum.reduce(chain, %{}, fn
      %{organization: organization}, acc ->
        organizations = Enum.filter(chain, fn cert -> cert[:organization] == organization end)
        Map.put(acc, organization, organizations)

      _, acc ->
        acc
    end)
  end

  defp process_matches_db_certificate(%{id: id, data: data} = certificate) when not is_nil(data) do
    type = to_string(certificate.type)
    attrs = certificate |> Map.delete(:type) |> Map.merge(%{name: certificate.subject, type: type})

    Repo.transaction(fn ->
      Cert |> where([c], c.type == ^type and c.data == ^certificate.data) |> Repo.delete_all()
      %Cert{id: id} |> cast(attrs, Cert.fields()) |> Repo.insert!()
    end)
  end

  defp process_matches_db_certificate(_), do: :ok

  # Certificates
  defp get_certs do
    Cert
    |> where([p], p.type in ["root", "tsp"] and p.active)
    |> join(:left, [p], c in Cert, on: c.parent == p.id and c.type == "ocsp" and c.active)
    |> select([p, c], [p.type, p.data, c.data])
    |> Repo.all()
  end

  def get_certificates_by_type(type) do
    Cert |> where([p], p.type == ^type and p.active) |> Repo.all()
  end

  defp deactivate_certificate(certificate) do
    certificate |> cast(%{active: false}, [:active]) |> Repo.update()
  end
end
