defmodule Capsule.Storages.S3Test do
  use ExUnit.Case

  import Mox

  alias Capsule.Storages.S3
  alias Capsule.{Locator, MockUpload, ExAwsMock}

  describe "put/1" do
    test "returns success tuple" do
      stub(ExAwsMock, :request, fn _ -> {:ok, nil} end)

      assert {:ok, %Locator{id: "/hi"}} = S3.put(%MockUpload{})
    end

    test "sets storage" do
      stub(ExAwsMock, :request, fn _ -> {:ok, nil} end)

      assert {:ok, %Locator{storage: "Elixir.Capsule.Storages.S3"}} = S3.put(%MockUpload{})
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

  describe "put/2 with valid s3 option" do
    test "adds corresponding AWS header to request" do
      stub(ExAwsMock, :request, fn %{headers: %{"x-amz-acl" => "public-read"}} -> {:ok, nil} end)

      assert {:ok, _} = S3.put(%MockUpload{}, s3_options: [acl: "public-read"])
    end
  end

  describe "put/2 with invalid s3 option" do
    test "is noop" do
      stub(ExAwsMock, :request, fn %{headers: %{}} -> {:ok, nil} end)

      assert {:ok, _} = S3.put(%MockUpload{}, s3_options: [bad: "option"])
    end
  end

  describe "read/1" do
    test "returns success tuple with data" do
      stub(ExAwsMock, :request, fn _ -> {:ok, %{body: "data"}} end)

      assert {:ok, "data"} = S3.read(%Locator{})
    end
  end

  describe "read/2 with bucket override" do
    test "makes request with override value" do
      stub(ExAwsMock, :request, fn %{bucket: "other"} -> {:ok, %{body: ""}} end)

      assert {:ok, _} = S3.read(%Locator{}, bucket: "other")
    end
  end

  describe "copy/1" do
    test "returns success tuple with data" do
      stub(ExAwsMock, :request, fn _ -> {:ok, nil} end)

      assert {:ok, %Locator{id: "new_path"}} =
               S3.copy(%Locator{id: "/path"}, "new_path")
    end
  end

  describe "copy/2 with bucket override" do
    test "makes request with override value" do
      stub(ExAwsMock, :request, fn %{bucket: "other"} -> {:ok, nil} end)

      assert {:ok, _} = S3.copy(%Locator{}, "new_path", bucket: "other")
    end
  end
end
