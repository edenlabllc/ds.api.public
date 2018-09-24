defmodule API.Web.APIView do
  @moduledoc false
  use API.Web, :view

  def render("show.json", %{digital_signature_info: digital_signature_info}) do
    digital_signature_info
  end
end
