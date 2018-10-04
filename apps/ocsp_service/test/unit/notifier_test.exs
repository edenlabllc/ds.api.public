defmodule OCSPServiceNotifierTest do
  use ExUnit.Case

  import DigitalSignatureTestHelper
  import Mox

  alias Core.InvalidContents
  alias OCSPService.Notifier
  alias Core.Repo
  alias Ecto.Adapters.SQL.Sandbox

  setup do
    :ok = Sandbox.checkout(Repo)
  end

  describe "process_invalid_sign/0 test" do
    test "stored content is valid, delete it from db" do
      data = get_data("test/fixtures/signed_le1.json")
      signed_content = get_signed_content(data)

      {:ok, content, [signature]} =
        DigitalSignatureLib.retrivePKCS7Data(signed_content, get_certs(), true)

      assert {:ok, id} =
               InvalidContents.store_invalid_content([signature], content)

      Notifier.process_invalid_sign()

      assert nil == InvalidContents.get_by_id(id)
    end
  end

  test "stored content is not valid, send email" do
    expect(EmailSenderMock, :send, fn _id ->
      :ok
    end)

    data = get_data("test/fixtures/hello_revoked.json")
    {:ok, signed_content} = Base.decode64(Map.get(data, "signed_content"))

    {:ok, content, [signature]} =
      DigitalSignatureLib.retrivePKCS7Data(signed_content, get_certs(), true)

    assert {:ok, id} =
             InvalidContents.store_invalid_content([signature], content)

    Notifier.process_invalid_sign()

    assert InvalidContents.get_by_id(id)
  end
end
