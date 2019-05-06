defmodule OCSPServiceTest do
  use Core.ModelCase, async: false

  import DigitalSignatureTestHelper
  import Mox

  alias Core.InvalidContent
  alias Core.InvalidContents

  setup :set_mox_global

  describe "store content to db" do
    test "success store content" do
      data = get_data("test/fixtures/signed_le1.json")
      signed_content = get_signed_content(data)
      {:ok, content, [signature] = signatures} = DigitalSignatureLib.retrivePKCS7Data(signed_content, get_certs(), true)
      assert {:ok, id} = InvalidContents.store_invalid_content(signatures, content)

      %InvalidContent{signatures: [db_signature], content: db_content} =
        invalid_conetn_record = InvalidContents.get_by_id(id)

      assert invalid_conetn_record == InvalidContents.random_invalid_content()
      assert db_signature == signature
      assert Jason.encode!(content) == db_content
      InvalidContents.delete(id)
      assert nil == InvalidContents.random_invalid_content()
    end

    test "update content" do
      assert {:ok, id} = InvalidContents.store_invalid_content([], "")
      assert {:ok, _} = InvalidContents.update_invalid_content(id, %{notified: true})
      assert %InvalidContent{notified: true, id: ^id} = InvalidContents.get_by_id(id)
    end
  end
end
