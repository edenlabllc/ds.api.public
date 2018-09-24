defmodule Core.Factory do
  @moduledoc false
  alias Core.Crl
  alias Core.RevokedSN

  use ExMachina.Ecto, repo: Core.Repo

  def crl_factory do
    %Crl{
      url: "example.com",
      next_update: NaiveDateTime.add(NaiveDateTime.utc_now(), 60, :second)
    }
  end

  def revoked_factory do
    %RevokedSN{
      url: "example.com",
      serial_number: sequence("1092827363459766")
    }
  end
end
