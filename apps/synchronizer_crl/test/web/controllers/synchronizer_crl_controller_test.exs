defmodule SynchronizerCrl.Web.SynchronizerCrlControllerTest do
  @moduledoc false
  use SynchronizerCrl.Web.ConnCase

  alias Plug.Conn

  test "add new crl url successfully", %{conn: conn} do
    resp =
      conn
      |> Conn.put_req_header("content-type", "application/json")
      |> post(synchronizer_crl_path(conn, :index), %{
        "crl_url" => "http://acsk.com/crl"
      })
      |> response(201)

    assert resp == ""
  end

  test "bad request", %{conn: conn} do
    resp =
      conn
      |> Conn.put_req_header("content-type", "application/json")
      |> post(synchronizer_crl_path(conn, :index), %{})
      |> response(400)

    assert resp == "$.crl_url required"
  end
end
