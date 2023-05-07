defmodule Capsule.Storages.RAM do
  alias Capsule.{Storage, Upload, Locator}

  @behaviour Storage

  @impl Storage
  def put(upload, _opts \\ []) do
    {:ok, contents} = Upload.contents(upload)

    {:ok, pid} = StringIO.open(contents)

    serialized_pid =
      pid
      |> :erlang.term_to_binary()
      |> Base.url_encode64()

    locator = %Locator{
      id: Path.join(serialized_pid, Upload.name(upload)),
      storage: to_string(__MODULE__)
    }

    {:ok, locator}
  end

  @impl Storage
  def copy(%Locator{id: id} = locator, path, _opts \\ []) do
    [serialized_pid, _] = decompose_id(id)

    new_locator = %Locator{locator | id: Path.join(serialized_pid, path)}

    {:ok, new_locator}
  end

  @impl Storage
  def delete(%Locator{id: id}, _opts \\ []) when is_binary(id) do
    pid = decode_pid!(id)

    {:ok, _} = StringIO.close(pid)

    :ok
  end

  @impl Storage
  def read(%Locator{id: id}, _opts \\ []),
    do: {:ok, id |> decode_pid! |> StringIO.contents() |> elem(0)}

  defp decompose_id(id), do: String.split(id, "/", parts: 2)

  defp decode_pid!(id) do
    id
    |> decompose_id
    |> List.first()
    |> Base.url_decode64!()
    |> :erlang.binary_to_term()
  end
end
