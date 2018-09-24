defmodule DigitalSignature.Behaviours.KafkaProducerBehaviour do
  @moduledoc false

  @callback publish_sigantures(request :: any) ::
              :ok
              | {:ok, integer}
              | {:error, :closed}
              | {:error, :inet.posix()}
              | {:error, any}
              | iodata
              | :leader_not_available
end
