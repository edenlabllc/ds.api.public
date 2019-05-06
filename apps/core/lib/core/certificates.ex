defmodule Core.Certificates do
  @moduledoc false

  import Ecto.Query
  alias Core.Cert
  alias Core.Repo

  # Certificates API
  def get_certificates do
    Enum.reduce(
      get_certs(),
      %{general: [], tsp: []},
      &process_cert(&1, &2)
    )
  end

  # Certificates
  defp get_certs do
    Cert
    |> where([p], p.type in ["root", "tsp"] and p.active)
    |> join(:left, [p], c in Cert, on: c.parent == p.id and c.type == "ocsp" and c.active)
    |> select([p, c], [p.type, p.data, c.data])
    |> Repo.all()
  end

  defp process_cert(["root", root_cert, ocsp_ert], %{general: general} = map) do
    Map.put(map, :general, [%{root: root_cert, ocsp: ocsp_ert} | general])
  end

  defp process_cert(["tsp", tsp_cert, _], %{tsp: tsp} = map) do
    Map.put(map, :tsp, [tsp_cert | tsp])
  end
end
