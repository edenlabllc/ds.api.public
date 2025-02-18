defmodule API.Web.FallbackController do
  @moduledoc """
  This controller should be used as `action_fallback` in rest of controllers to remove duplicated error handling.
  """
  use API.Web, :controller

  def call(conn, {:error, :bad_request}) do
    conn
    |> put_status(:bad_request)
    |> put_view(EView.Views.Error)
    |> render(:"400")
  end

  def call(conn, {:error, :access_denied}) do
    conn
    |> put_status(:unauthorized)
    |> put_view(EView.Views.Error)
    |> render(:"401")
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(EView.Views.Error)
    |> render(:"404")
  end

  def call(conn, {:error, {:nif_service_timeout, _error}}) do
    conn
    |> put_status(424)
    |> put_view(EView.Views.Error)
    |> render(:"424")
  end

  def call(conn, {:error, :unavailable}) do
    conn
    |> put_status(:service_unavailable)
    |> put_view(EView.Views.Error)
    |> render(:"503", %{message: "service unavailable"})
  end

  def call(conn, nil) do
    conn
    |> put_status(:not_found)
    |> put_view(EView.Views.Error)
    |> render(:"404")
  end

  def call(conn, {:error, {:invalid_content, error_message, content}}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(API.Web.InvalidContentView)
    |> render(
      "invalid.json",
      error_message: error_message,
      content: content
    )
  end

  def call(conn, {:error, validation_errors}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(EView.Views.ValidationError)
    |> render(:"422", schema: validation_errors)
  end
end
