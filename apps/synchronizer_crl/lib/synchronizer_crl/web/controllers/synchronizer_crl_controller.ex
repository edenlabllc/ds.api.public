defmodule SynchronizerCrl.Web.SynchronizerCrlController do
  @moduledoc false

  use SynchronizerCrl.Web, :controller
  require Logger

  alias SynchronizerCrl.CrlService

  def index(conn, %{"crl_url" => url}) do
    send(CrlService, {:update, url})
    send_resp(conn, 201, "")
  end

  def index(conn, _params) do
    send_resp(conn, 400, "$.crl_url required")
  end
end
