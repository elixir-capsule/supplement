defmodule Capsule.Storages.RAMTest do
  use ExUnit.Case
  doctest Capsule

  alias Capsule.Storages.RAM
  alias Capsule.{Encapsulation, MockUpload}

  describe "put/1" do
    test "returns success tuple" do
      assert {:ok, %Encapsulation{}} = RAM.put(%MockUpload{})
    end

    test "prefixes id with pid serialization" do
      {:ok, %Encapsulation{id: id}} = RAM.put(%MockUpload{})

      [serialized_pid, _] = String.split(id, "/")

      assert serialized_pid
             |> Base.url_decode64!()
             |> :erlang.binary_to_term()
    end

    test "suffixes id with name" do
      {:ok, %Encapsulation{id: id}} = RAM.put(%MockUpload{})

      [_, name] = String.split(id, "/")

      assert name == "hi"
    end
  end

  describe "copy/1" do
    test "returns success tuple" do
      assert {:ok, _} = RAM.copy(%Encapsulation{id: "fakepid/path"}, "/new_path/name")
    end

    test "replaces existing path" do
      assert {:ok, %Encapsulation{id: "fakepid/new_path/name"}} =
               RAM.copy(%Encapsulation{id: "fakepid/path/to/existing"}, "/new_path/name")
    end
  end

  describe "delete/1" do
    setup :build_ram_file

    test "returns success atom", %{encapsulation: encapsulation} do
      assert :ok = RAM.delete(encapsulation)
    end
  end

  describe "read/1" do
    setup :build_ram_file

    test "returns success tuple", %{encapsulation: encapsulation} do
      assert {:ok, _} = RAM.read(encapsulation)
    end

    test "returns file contents", %{encapsulation: encapsulation} do
      assert {_, "some data"} = RAM.read(encapsulation)
    end
  end

  defp build_ram_file(_context) do
    {:ok, pid} = StringIO.open("some data")

    serialized_pid =
      pid
      |> :erlang.term_to_binary()
      |> Base.url_encode64()

    %{encapsulation: %Encapsulation{id: Path.join(serialized_pid, "hi")}}
  end
end
