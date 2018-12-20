defmodule SynchronizerCrl.Web.SynchronizerCrlControllerTest do
  @moduledoc false
  use SynchronizerCrl.Web.ConnCase, async: false

  alias Plug.Conn

  describe "send new urls" do
    test "add new crl url successfully", %{conn: conn} do
      Enum.each(~w(http://acsk.com/crl http://acsk.privatbank.ua/crl/PB-S11.crl), fn url ->
        resp =
          conn
          |> Conn.put_req_header("content-type", "application/json")
          |> post(synchronizer_crl_path(conn, :index), %{
            "crl_url" => url
          })
          |> response(201)

        assert resp == ""
      end)

      Supervisor.terminate_child(
        SynchronizerCrl.Supervisor,
        SynchronizerCrl.CrlService
      )
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
end
