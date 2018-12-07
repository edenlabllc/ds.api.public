defmodule OCSPServiceRecheckerTest do
  use OCSPService.Case, async: false

  import DigitalSignatureTestHelper
  import Mox

  alias Core.InvalidContents
  alias OCSPService.ReChecker

  setup :verify_on_exit!
  setup :set_mox_global

  describe ":recheck works" do
    test "send invalid content first time" do
      expect(EmailSenderMock, :send, fn _id ->
        :ok
      end)

      data = get_data("test/fixtures/hello_revoked.json")
      {:ok, signed_content} = Base.decode64(Map.get(data, "signed_content"))

      {:ok, content, [signature]} =
        DigitalSignatureLib.retrivePKCS7Data(signed_content, get_certs(), true)

      {:ok, id} = InvalidContents.store_invalid_content([signature], content)
      send(ReChecker, {:recheck, self(), id, 0, [signature]})
      assert_receive :send_email, 1000
    end

    test "send invalid content last time" do
      expect(EmailSenderMock, :send, fn _id -> :ok end)
      data = get_data("test/fixtures/hello_revoked.json")
      {:ok, signed_content} = Base.decode64(Map.get(data, "signed_content"))

      {:ok, content, [signature]} =
        DigitalSignatureLib.retrivePKCS7Data(signed_content, get_certs(), true)

      {:ok, id} = InvalidContents.store_invalid_content([signature], content)
      send(ReChecker, {:recheck, self(), id, 1, [signature]})
      assert_receive :send_email, 1000
    end

    test "delete if content valid" do
      data = get_data("test/fixtures/signed_le1.json")
      signed_content = get_signed_content(data)

      {:ok, content, [signature]} =
        DigitalSignatureLib.retrivePKCS7Data(signed_content, get_certs(), true)

      {:ok, id} = InvalidContents.store_invalid_content([signature], content)
      send(ReChecker, {:recheck, self(), id, 1, [signature]})
      assert_receive :valid, 1000
    end
  end

  describe ":start_recheck works" do
    test "do not send email if notification already send" do
      data = get_data("test/fixtures/hello_revoked.json")
      {:ok, signed_content} = Base.decode64(Map.get(data, "signed_content"))

      {:ok, content, [signature]} =
        DigitalSignatureLib.retrivePKCS7Data(signed_content, get_certs(), true)

      {:ok, id} = InvalidContents.store_invalid_content([signature], content)
      InvalidContents.update_invalid_content(id, %{notified: true})
      ReChecker.start_recheck(self())
    end

    test "send email notfication" do
      expect(EmailSenderMock, :send, fn _id -> :ok end)
      data = get_data("test/fixtures/hello_revoked.json")
      {:ok, signed_content} = Base.decode64(Map.get(data, "signed_content"))

      {:ok, content, [signature]} =
        DigitalSignatureLib.retrivePKCS7Data(signed_content, get_certs(), true)

      {:ok, _id} = InvalidContents.store_invalid_content([signature], content)
      ReChecker.start_recheck(self())
      assert_receive :send_email, 1000
    end
  end
end
