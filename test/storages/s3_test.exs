defmodule Capsule.Storages.S3Test do
  use ExUnit.Case

  import Mox

  alias Capsule.Storages.S3
  alias Capsule.{MockUpload, ExAwsMock}

  describe "put/1" do
    test "returns success tuple" do
      stub(ExAwsMock, :request, fn _, _ -> {:ok, nil} end)

      assert {:ok, "/hi"} = S3.put(%MockUpload{})
    end

    test "returns error when request fails" do
      stub(ExAwsMock, :request, fn _, _ -> {:error, nil} end)

      assert {:error, _} = S3.put(%MockUpload{})
    end
  end

  describe "put/2 with bucket override" do
    test "makes request with override value" do
      stub(ExAwsMock, :request, fn %{bucket: "other"}, _ -> {:ok, nil} end)

      assert {:ok, _} = S3.put(%MockUpload{}, bucket: "other")
    end
  end

  describe "put/2 with valid s3 option" do
    test "adds corresponding AWS header to request" do
      stub(ExAwsMock, :request, fn %{headers: %{"x-amz-acl" => "public-read"}}, _ -> {:ok, nil} end)

      assert {:ok, _} = S3.put(%MockUpload{}, s3_options: [acl: "public-read"], upload_with: :contents)
    end
  end

  describe "put/2 with invalid s3 option" do
    test "is noop" do
      stub(ExAwsMock, :request, fn %{headers: %{}}, _ -> {:ok, nil} end)

      assert {:ok, _} = S3.put(%MockUpload{}, s3_options: [bad: "option"], upload_with: :contents)
    end
  end

  describe "read/1" do
    test "returns success tuple with data" do
      stub(ExAwsMock, :request, fn _, _ -> {:ok, %{body: "data"}} end)

      assert {:ok, "data"} = S3.read("fake")
    end
  end

  describe "read/2 with bucket override" do
    test "makes request with override value" do
      stub(ExAwsMock, :request, fn %{bucket: "other"}, _ -> {:ok, %{body: ""}} end)

      assert {:ok, _} = S3.read("fake", bucket: "other")
    end
  end

  describe "copy/1" do
    test "returns success tuple" do
      stub(ExAwsMock, :request, fn _, _ -> {:ok, nil} end)

      assert {:ok, "new_path"} = S3.copy("/path", "new_path")
    end
  end

  describe "copy/2 with bucket override" do
    test "makes request with override value" do
      stub(ExAwsMock, :request, fn %{bucket: "other"}, _ -> {:ok, nil} end)

      assert {:ok, _} = S3.copy("fake", "new_path", bucket: "other")
    end
  end
end
