defmodule Capsule.Storages.RAM do
  alias Capsule.{Storage, Upload, Encapsulation}

  @behaviour Storage

  @impl Storage
  def put(upload, _opts \\ []) do
    {:ok, contents} = Upload.contents(upload)

    {:ok, pid} = StringIO.open(contents)

    serialized_pid =
      pid
      |> :erlang.term_to_binary()
      |> Base.url_encode64()

    encapsulation = %Encapsulation{
      id: Path.join(serialized_pid, Upload.name(upload)),
      storage: to_string(__MODULE__)
    }

    {:ok, encapsulation}
  end

  @impl Storage
  def copy(%Encapsulation{id: id} = encapsulation, path, _opts \\ []) do
    [serialized_pid, _] = decompose_id(id)

    new_encapsulation = %Encapsulation{encapsulation | id: Path.join(serialized_pid, path)}

    {:ok, new_encapsulation}
  end

  @impl Storage
  def delete(%Encapsulation{id: id}, _opts \\ []) when is_binary(id) do
    pid = decode_pid!(id)

    {:ok, _} = StringIO.close(pid)

    :ok
  end

  @impl Storage
  def read(%Encapsulation{id: id}, _opts \\ []),
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
