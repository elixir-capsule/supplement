defmodule Capsule.Storages.S3Test do
  use ExUnit.Case

  import Mox

  alias Capsule.Storages.S3
  alias Capsule.{Encapsulation, MockUpload, ExAwsMock}

  describe "put/1" do
    test "prefixes id with bucket" do
      stub(ExAwsMock, :request, fn _ -> {:ok, nil} end)

      assert {:ok, %Encapsulation{id: "fake/hi"}} = S3.put(%MockUpload{}, bucket: "fake")
    end

    test "sets size" do
      stub(ExAwsMock, :request, fn _ -> {:ok, nil} end)

      assert {:ok, %Encapsulation{size: 14}} = S3.put(%MockUpload{}, bucket: "fake")
    end

    test "sets storage" do
      stub(ExAwsMock, :request, fn _ -> {:ok, nil} end)

      assert {:ok, %Encapsulation{storage: "Elixir.Capsule.Storages.S3"}} = S3.put(%MockUpload{}, bucket: "fake")
    end

    test "returns error when request fails" do
      stub(ExAwsMock, :request, fn _ -> {:error, nil} end)

      assert {:error, _} = S3.put(%MockUpload{}, bucket: "fake")
    end
  end

  describe "put/2 with valid s3 option" do
    test "adds corresponding AWS header to request" do
      stub(ExAwsMock, :request, fn %{headers: %{"x-amz-acl" => "public-read"}} -> {:ok, nil} end)

      assert {:ok, _} = S3.put(%MockUpload{}, bucket: "fake", s3_options: [acl: "public-read"])
    end
  end

  describe "put/2 with invalid s3 option" do
    test "is noop" do
      stub(ExAwsMock, :request, fn %{headers: %{}} -> {:ok, nil} end)

      assert {:ok, _} = S3.put(%MockUpload{}, bucket: "fake", s3_options: [bad: "option"])
    end
  end

  describe "read/1" do
    test "returns success tuple with data" do
      stub(ExAwsMock, :request, fn _ -> {:ok, %{body: "data"}} end)

      assert {:ok, "data"} = S3.read(%Encapsulation{id: "fake/hi"})
    end
  end

  describe "copy/1" do
    test "returns success tuple with data" do
      stub(ExAwsMock, :request, fn _ -> {:ok, nil} end)

      assert {:ok, %Encapsulation{id: "new_path"}} =
               S3.copy(%Encapsulation{id: "/path"}, "new_path", bucket: "fake")
    end
  end
end
