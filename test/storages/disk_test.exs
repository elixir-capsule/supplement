defmodule Capsule.Storages.DiskTest do
  use ExUnit.Case
  doctest Capsule

  alias Capsule.Storages.Disk
  alias Capsule.MockUpload

  describe "put/1" do
    test "returns success tuple" do
      assert {:ok, _} = Disk.put(%MockUpload{})

      on_exit(fn -> File.rm!("tmp/hi") end)
    end

    test "writes file to path from name" do
      Disk.put(%MockUpload{name: "subdir/name"})

      assert File.exists?("tmp/subdir/name")

      on_exit(fn -> File.rm!("tmp/subdir/name") end)
    end

    test "writes file to path with prefix" do
      Disk.put(%MockUpload{name: "name"}, prefix: "subdir")

      assert File.exists?("tmp/subdir/name")

      on_exit(fn -> File.rm!("tmp/subdir/name") end)
    end

    test "returns error when file already exists" do
      File.write!("tmp/name", "data")

      assert {:error, _} = Disk.put(%MockUpload{name: "name"})

      on_exit(fn -> File.rm!("tmp/name") end)
    end

    test "overwrites existing file when force is set to true" do
      File.write!("tmp/name", "data")

      Disk.put(%MockUpload{name: "name", content: "new"}, force: true)

      assert "new" = File.read!("tmp/name")

      on_exit(fn -> File.rm!("tmp/name") end)
    end
  end

  describe "read/1" do
    test "returns success tuple with data" do
      File.write!("tmp/path", "data")

      assert {:ok, "data"} = Disk.read("path")

      on_exit(fn -> File.rm!("tmp/path") end)
    end
  end

  describe "stream!/1" do
    test "returns enum of file contents" do
      File.write!("tmp/path", "data")

      assert "data" = "path" |> Disk.stream!() |> Enum.join()

      on_exit(fn -> File.rm!("tmp/path") end)
    end
  end
end
