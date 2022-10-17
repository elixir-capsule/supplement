defmodule Capsule.Storages.DiskTest do
  use ExUnit.Case
  doctest Capsule

  alias Capsule.Storages.Disk
  alias Capsule.{Encapsulation, MockUpload}

  describe "put/1" do
    test "returns success tuple" do
      assert {:ok, _} = Disk.put(%MockUpload{})

      on_exit(fn -> File.rm!("hi") end)
    end

    test "sets size" do
      assert {:ok, %Encapsulation{size: 14}} = Disk.put(%MockUpload{})

      on_exit(fn -> File.rm!("hi") end)
    end

    test "sets storage" do
      assert {:ok, %Encapsulation{storage: "Elixir.Capsule.Storages.Disk"}} =
               Disk.put(%MockUpload{})

      on_exit(fn -> File.rm!("hi") end)
    end

    test "writes file to path from name" do
      Disk.put(%MockUpload{name: "subdir/name"})

      assert File.exists?("subdir/name")

      on_exit(fn -> File.rm!("subdir/name") end)
    end

    test "writes file to path with prefix" do
      Disk.put(%MockUpload{name: "name"}, prefix: "subdir")

      assert File.exists?("subdir/name")

      on_exit(fn -> File.rm!("subdir/name") end)
    end

    test "returns error when file already exists" do
      File.write!("name", "data")

      assert {:error, _} = Disk.put(%MockUpload{name: "name"})

      on_exit(fn -> File.rm!("name") end)
    end

    test "overwrites existing file when force is set to true" do
      File.write!("name", "data")

      Disk.put(%MockUpload{name: "name", content: "new"}, force: true)

      assert "new" = File.read!("name")

      on_exit(fn -> File.rm!("name") end)
    end
  end

  describe "read/1" do
    test "returns success tuple with data" do
      File.write!("path", "data")

      assert {:ok, "data"} = Disk.read(%Encapsulation{id: "path"})

      on_exit(fn -> File.rm!("path") end)
    end
  end

  describe "copy/1" do
    test "returns success tuple with data" do
      File.write!("path", "data")

      assert {:ok, %Encapsulation{id: "new_path"}} =
               Disk.copy(%Encapsulation{id: "path"}, "new_path")

      on_exit(fn -> File.rm!("new_path") end)
    end

    test "creates path" do
      File.write!("path", "data")

      assert {:ok, %Encapsulation{id: "subdir/new_path"}} =
               Disk.copy(%Encapsulation{id: "path"}, "subdir/new_path")

      on_exit(fn -> File.rm!("subdir/new_path") end)
    end
  end
end
