defmodule OCSPServiceConsumerTest do
  use ExUnit.Case

  import DigitalSignatureTestHelper
  import Mox

  alias Core.InvalidContents
  alias Core.Repo
  alias Ecto.Adapters.SQL.Sandbox
  alias OCSPService.Kafka.GenConsumer

  setup do
    :ok = Sandbox.checkout(Repo)

    Sandbox.mode(Repo, {:shared, self()})
  end

  describe "process_invalid_sign/0 test" do
    test "stored content is valid, delete it from db" do
      data = get_data("test/fixtures/signed_le1.json")
      signed_content = get_signed_content(data)

      {:ok, content, [signature]} =
        DigitalSignatureLib.retrivePKCS7Data(signed_content, get_certs(), true)

      GenConsumer.online_check_signed_content([signature], content)

      assert nil == InvalidContents.random_invalid_content()
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

    GenConsumer.online_check_signed_content([signature], content)

    assert InvalidContents.random_invalid_content()
  end
end
