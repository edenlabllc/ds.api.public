defmodule Core.Factory do
  @moduledoc false
  alias Core.CRL

  use ExMachina.Ecto, repo: Core.Repo

  def crl_factory do
    %CRL{
      url: "example.com",
      next_update: NaiveDateTime.add(NaiveDateTime.utc_now(), 60, :second)
    }
  end
end
