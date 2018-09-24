defmodule DigitalSignatureTestHelper do
  @moduledoc """
  common test functions
  """
  def atomize_keys(map) do
    map
    |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end)
    |> Enum.into(%{})
  end

  def decode_content(result) do
    Jason.decode!(result.content)
  end

  def get_data(json_file) do
    file = File.read!(json_file)
    json = Jason.decode!(file)

    json["data"]
  end

  def get_signed_content(data) do
    data["signed_content"]
    |> Base.decode64!()
  end

  def get_certs do
    general = [
      %{
        root: File.read!("test/fixtures/CA-DFS.cer"),
        ocsp: File.read!("test/fixtures/OCSP-IDDDFS-080218.cer")
      },
      %{
        root: File.read!("test/fixtures/CA-IDDDFS-080218.cer"),
        ocsp: File.read!("test/fixtures/OCSP-IDDDFS-080218.cer")
      },
      %{
        root: File.read!("test/fixtures/CA-Justice.cer"),
        ocsp: File.read!("test/fixtures/OCSP-Server Justice.cer")
      },
      %{
        root: File.read!("test/fixtures/CA-3004751DEF2C78AE010000000100000049000000.cer"),
        ocsp: File.read!("test/fixtures/CAOCSPServer-D84EDA1BB9381E802000000010000001A000000.cer")
      },
      %{
        root: File.read!("test/fixtures/cert1599998-root.crt"),
        ocsp: File.read!("test/fixtures/cert14493930-oscp.crt")
      }
    ]

    tsp = [
      File.read!("test/fixtures/CA-TSP-DFS.cer"),
      File.read!("test/fixtures/TSP-Server Justice.cer"),
      File.read!("test/fixtures/CATSPServer-3004751DEF2C78AE02000000010000004A000000.cer"),
      File.read!("test/fixtures/cert14491837-tsp.crt"),
      File.read!("test/fixtures/TSA-IDDDFS-140218.cer")
    ]

    %{general: general, tsp: tsp}
  end
end
