defmodule Core.ProviderCertificates do
  @moduledoc """
  read pem certificate chain file
  """

  alias Core.DateUtils
  require Logger

  # asn.1 extentions
  @authority_key {2, 5, 29, 35}
  @suject_key {2, 5, 29, 14}
  @common_name {2, 5, 4, 3}
  @organization_name {2, 5, 4, 10}

  def pem_certificate_chain_data(pem_binary) do
    %{general: general, tsp: tsp} = pem_extended_chain(pem_binary)

    general_data =
      Enum.reduce(general, [], fn pair, acc ->
        pair = Enum.reduce(pair, %{}, fn {type, cert}, pairs -> Map.put(pairs, type, cert[:data]) end)
        [pair | acc]
      end)

    %{general: general_data, tsp: tsp}
  end

  def pem_extended_chain(pem_binary) do
    pem_binary
    |> :public_key.pem_decode()
    |> Enum.reduce([], &get_key_info(&1, &2))
    |> Enum.reduce(%{tsp: [], general: %{}}, &make_certificate_pairs(&1, &2))
    |> process_certificates()
  end

  defp make_certificate_pairs(%{type: :tsp, data: data}, certificates) do
    Map.put(certificates, :tsp, [data | certificates[:tsp]])
  end

  defp make_certificate_pairs(%{type: type} = cert, certificates) when type in ~w(root ocsp)a do
    general = certificates.general
    id = get_certificate_identifier(cert)
    certificate = general |> Map.get(id, %{}) |> Map.put(type, cert)
    Map.put(certificates, :general, Map.put(general, id, certificate))
  end

  defp make_certificate_pairs(_, certificates), do: certificates

  defp process_certificates(%{general: general_map, tsp: tsp}) do
    # Filter certificates because of subject authority and key authority for root
    general =
      general_map
      |> Enum.map(fn {_identity, info} -> info end)
      |> MapSet.new()
      |> MapSet.to_list()
      |> Enum.map(fn pair -> Map.merge(%{ocsp: %{}}, pair) end)

    %{general: general, tsp: tsp}
  end

  @doc """
  Parse certificates, decode certificate values and add to chain if types matches and valid
  """
  def get_key_info({:Certificate, data, :not_encrypted}, certificates) do
    {certificate, valid_from, valid_to} = decode_certificate_entry(data)

    if :gt == DateTime.compare(valid_to, DateTime.utc_now()) do
      [form_key_info(certificate, data, valid_from, valid_to) | certificates]
    else
      certificates
    end
  end

  def get_key_info(certificate, certificates) do
    Logger.warn("Invalid certitificate in chain : #{inspect(certificate)}")
    certificates
  end

  def decode_certificate_entry(bin_certificate) do
    {:Certificate, certificate, _, _} = :public_key.pem_entry_decode({:Certificate, bin_certificate, :not_encrypted})
    {:Validity, {:utcTime, validy_from}, {:utcTime, validy_to}} = elem(certificate, 5)
    valid_to = DateUtils.convert_date!(validy_to)
    valid_from = DateUtils.convert_date!(validy_from)
    {certificate, valid_from, valid_to}
  end

  def form_key_info(certificate, data, valid_from, valid_to) do
    serial_number = elem(certificate, 2)
    extensions = elem(certificate, 10)
    {:rdnSequence, rdn_sequence} = elem(certificate, 6)
    auth_identifier = get_certificate_field(extensions, @authority_key, :AuthorityKeyIdentifier)
    subectj_identifier = get_certificate_field(extensions, @suject_key, :SubjectKeyIdentifier)
    subject = get_certificate_field(rdn_sequence, @common_name, :X520CommonName)
    organization = get_certificate_field(rdn_sequence, @organization_name, :X520OrganizationName)
    type = cert_type_by_subject(subject)

    %{
      organization: organization,
      auth_identifier: auth_identifier,
      subectj_identifier: subectj_identifier,
      subject: subject,
      type: type,
      data: data,
      serial_number: serial_number,
      valid: %{from: valid_from, to: valid_to}
    }
  end

  defp get_certificate_field(sequence, extention, name) do
    Enum.reduce_while(sequence, nil, fn
      [{:AttributeTypeAndValue, ext, data}], _ when ext == extention and is_binary(data) ->
        {:halt, der_decode(name, data)}

      {:Extension, ext, _, data}, _ when ext == extention and is_binary(data) ->
        {:halt, der_decode(name, data)}

      _, _ ->
        {:cont, nil}
    end)
  end

  defp der_decode(extention_name, data) when is_binary(data) do
    case :public_key.der_decode(extention_name, data) do
      {_, authority_key_identifier, _, _} -> authority_key_identifier
      {_, decoded_data} -> decoded_data
      decoded_data when is_binary(decoded_data) -> decoded_data
    end
  rescue
    # Provider can return uft non-encoded data instead of der encode
    _ -> data
  end

  defp cert_type_by_subject(subject) do
    # do regexp instead of pattern matching because type can be not only the first item
    cond do
      Regex.run(~r/OCSP/, subject) -> :ocsp
      Regex.run(~r/CMP/, subject) -> :cmp
      Regex.run(~r/TSP/, subject) -> :tsp
      true -> :root
    end
  end

  defp get_certificate_identifier(%{type: :root, subectj_identifier: id}), do: id
  defp get_certificate_identifier(%{type: :ocsp, auth_identifier: id}), do: id
end
