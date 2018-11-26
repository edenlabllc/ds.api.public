defmodule OCSPServiceRecheckerTest do
  use ExUnit.Case

  import DigitalSignatureTestHelper
  import Mox

  alias Core.InvalidContents
  alias Core.Repo
  alias Ecto.Adapters.SQL.Sandbox
  alias OCSPService.ReChecker

  setup :verify_on_exit!
  setup :set_mox_global

  setup do
    :ok = Sandbox.checkout(Repo)

    Sandbox.mode(Repo, {:shared, self()})
    :ok
  end

  describe "rechecker gen server works" do
    setup do
      expect(EmailSenderMock, :send, fn _id ->
        :ok
      end)

      :ok
    end

    test "send invalid content first time" do
      data = get_data("test/fixtures/hello_revoked.json")
      {:ok, signed_content} = Base.decode64(Map.get(data, "signed_content"))

      {:ok, content, [signature]} =
        DigitalSignatureLib.retrivePKCS7Data(signed_content, get_certs(), true)

      {:ok, id} = InvalidContents.store_invalid_content([signature], content)
      send(ReChecker, {:recheck, self(), id, 1, [signature]})
      assert_receive :send_email, 10000
    end
  end
end
