defmodule Capsule.Uploads.URI do
  use ExUnit.Case
  doctest Capsule

  setup do
    %{mock_server: Bypass.open()}
  end

  describe "contents/1 with non 200 response code" do
    setup %{mock_server: mock_server} do
      Bypass.stub(mock_server, "GET", "/file-path", fn conn ->
        Plug.Conn.resp(conn, 422, "some error")
      end)

      %{
        result:
          Capsule.Upload.contents(URI.parse("http://localhost:#{mock_server.port}/file-path"))
      }
    end

    test "returns error tuple", %{result: result} do
      assert {:error, _} = result
    end
  end
end
