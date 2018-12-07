defmodule OCSPService.SenderBehaviour do
  @moduledoc false
  @callback send(id :: binary) :: term
end
