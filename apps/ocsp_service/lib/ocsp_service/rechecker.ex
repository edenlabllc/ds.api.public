defmodule OCSPService.ReChecker do
  @moduledoc """
  re-check does signatures really valid
  """
  use GenServer
  use Confex, otp_app: :ocsp_service

  alias Core.InvalidContent
  alias Core.InvalidContents
  alias DigitalSignature.NifServiceAPI

  @email_sender Application.get_env(:ocsp_service, :api_resolvers)[
                  :email_sender
                ]

  def init({recheck_timeout, max_recheck_tries}) do
    {:ok, {recheck_timeout, max_recheck_tries}}
  end

  def handle_info(
        {:recheck, pid, id, n, signatures},
        {recheck_timeout, max_recheck_tries} = state
      ) do
    is_invalid? = NifServiceAPI.signatures_valid_online?(signatures)

    case {is_invalid?, n} do
      {true, _} ->
        send(pid, :valid)
        InvalidContents.delete(id)

      {false, n} when n < max_recheck_tries ->
        Process.send_after(
          self(),
          {:recheck, pid, id, n + 1, signatures},
          recheck_timeout
        )

      {false, _} ->
        @email_sender.send(id)
        send(pid, :send_email)
        InvalidContents.update_invalid_content(id, %{notified: true})
    end

    {:noreply, state}
  end

  # Handle unexpected messages
  def handle_info(_any, state) do
    {:noreply, state}
  end

  def start_link({recheck_timeout, max_recheck_tries}) do
    {:ok, pid} =
      GenServer.start_link(
        __MODULE__,
        {recheck_timeout, max_recheck_tries},
        name: __MODULE__
      )

    on_start()
    {:ok, pid}
  end

  def on_start do
    with :prod <- config()[:env],
         %InvalidContent{id: id, signatures: signatures} <-
           InvalidContents.random_invalid_content() do
      send(ReChecker, {:recheck, __MODULE__, id, 0, signatures})
    else
      _ -> :ok
    end
  end
end
