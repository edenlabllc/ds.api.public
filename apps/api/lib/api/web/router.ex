defmodule API.Web.Router do
  @moduledoc """
  The router provides a set of macros for generating routes
  that dispatch to specific controllers and actions.
  Those macros are named after HTTP verbs.

  More info at: https://hexdocs.pm/phoenix/Phoenix.Router.html
  """
  use API.Web, :router
  use Plug.ErrorHandler

  alias Plug.LoggerJSON

  require Logger

  pipeline :api do
    plug(:accepts, ["json"])
    plug(:put_secure_browser_headers)

    # Uncomment to enable versioning of your API
    # plug Multiverse, gates: [
    #   "2016-07-31": API.Web.InitialGate
    # ]

    # You can allow JSONP requests by uncommenting this line:
    # plug :allow_jsonp
  end

  scope "/", API.Web do
    pipe_through(:api)

    post("/digital_signatures", APIController, :index)
  end

  defp handle_errors(%Plug.Conn{status: 500} = conn, %{
         kind: kind,
         reason: reason,
         stack: stacktrace
       }) do
    LoggerJSON.log_error(kind, reason, stacktrace)
    Logger.configure(truncate: :infinity)

    Logger.error(
      "Internal server error, reason: #{inspect(reason)}, request body: #{
        inspect(conn.body_params)
      }"
    )

    send_resp(
      conn,
      500,
      Jason.encode!(%{errors: %{detail: "Internal server error"}})
    )
  end

  defp handle_errors(_, _), do: nil
end
