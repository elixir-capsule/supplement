defmodule Capsule.Storages.S3Test do
  use ExUnit.Case

  import Mox

  alias Capsule.Storages.S3
  alias Capsule.{Encapsulation, MockUpload, ExAwsMock}

  describe "put/1" do
    test "returns success tuple" do
      stub(ExAwsMock, :request, fn _ -> {:ok, nil} end)

      assert {:ok, %Encapsulation{id: "/hi"}} = S3.put(%MockUpload{})
    end

    test "sets size" do
      stub(ExAwsMock, :request, fn _ -> {:ok, nil} end)

      assert {:ok, %Encapsulation{size: 14}} = S3.put(%MockUpload{})
    end

    test "returns error when request fails" do
      stub(ExAwsMock, :request, fn _ -> {:error, nil} end)

      assert {:error, _} = S3.put(%MockUpload{})
    end
  end

  describe "put/2 with bucket override" do
    test "makes request with override value" do
      stub(ExAwsMock, :request, fn %{bucket: "other"} -> {:ok, nil} end)

      assert {:ok, _} = S3.put(%MockUpload{}, bucket: "other")
    end
  end

  describe "open/1" do
    test "returns success tuple with data" do
      stub(ExAwsMock, :request, fn _ -> {:ok, %{body: "data"}} end)

      assert {:ok, "data"} = S3.open(%Encapsulation{})
    end
  end

  describe "open/2 with bucket override" do
    test "makes request with override value" do
      stub(ExAwsMock, :request, fn %{bucket: "other"} -> {:ok, %{body: ""}} end)

      assert {:ok, _} = S3.open(%Encapsulation{}, bucket: "other")
    end
  end

  describe "copy/1" do
    test "returns success tuple with data" do
      stub(ExAwsMock, :request, fn _ -> {:ok, nil} end)

      assert {:ok, %Encapsulation{id: "new_path"}} =
               S3.copy(%Encapsulation{id: "/path"}, "new_path")
    end
  end

  describe "copy/2 with bucket override" do
    test "makes request with override value" do
      stub(ExAwsMock, :request, fn %{bucket: "other"} -> {:ok, nil} end)

      assert {:ok, _} = S3.copy(%Encapsulation{}, "new_path", bucket: "other")
    end
  end
end
