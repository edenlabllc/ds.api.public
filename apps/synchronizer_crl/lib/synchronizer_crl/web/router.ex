defmodule SynchronizerCrl.Web.Router do
  @moduledoc """
  The router provides a set of macros for generating routes
  that dispatch to specific controllers and actions.
  Those macros are named after HTTP verbs.

  More info at: https://hexdocs.pm/phoenix/Phoenix.Router.html
  """
  use SynchronizerCrl.Web, :router
  use Plug.ErrorHandler

  alias Plug.LoggerJSON

  require Logger

  pipeline :api do
    plug(:accepts, ["json"])
    plug(:put_secure_browser_headers)
  end

  scope "/", SynchronizerCrl.Web do
    pipe_through(:api)

    post("/crl-url", SynchronizerCrlController, :index)
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
