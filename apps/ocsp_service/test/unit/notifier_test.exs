defmodule OCSPServiceNotifierTest do
  use OCSPService.Case, async: false

  import DigitalSignatureTestHelper
  import Mox

  alias Core.InvalidContent
  alias Core.InvalidContents
  alias OCSPService.Kafka.GenConsumer

  setup :set_mox_global
  setup :verify_on_exit!

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
    stub(EmailSenderMock, :send, fn _id -> :ok end)
    data = get_data("test/fixtures/hello_revoked.json")
    {:ok, signed_content} = Base.decode64(Map.get(data, "signed_content"))

    {:ok, content, [signature]} =
      DigitalSignatureLib.retrivePKCS7Data(signed_content, get_certs(), true)

    GenConsumer.online_check_signed_content([signature], content)
    assert InvalidContents.random_invalid_content()
  end

  test "stored content is not valid, privatbank, content request json send email" do
    data = get_data("test/fixtures/privatbank.json")
    {:ok, signed_content} = Base.decode64(Map.get(data, "signed_content"))

    {:ok, content, [signature]} =
      DigitalSignatureLib.retrivePKCS7Data(signed_content, get_certs(), true)

    GenConsumer.online_check_signed_content([signature], content)

    assert %InvalidContent{content: content} =
             InvalidContents.random_invalid_content()

    assert {:ok, %{"content" => _}} = Poison.decode(content)
  end
end
