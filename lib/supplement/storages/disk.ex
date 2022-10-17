defmodule Capsule.Storages.Disk do
  alias Capsule.{Storage, Upload, Encapsulation}

  @behaviour Storage

  @impl Storage
  def put(upload, opts \\ []) do
    with destination <- Path.join(opts[:prefix] || ".", Upload.name(upload)),
         true <-
           !File.exists?(destination) || opts[:force] ||
             {:error, "File already exists at upload destination"},
         {:ok, contents} <- Upload.contents(upload) do
      create_path!(destination)

      File.write!(destination, contents)

      encapsulation = %Encapsulation{
        id: destination,
        size: byte_size(contents),
        storage: to_string(__MODULE__)
      }

      {:ok, encapsulation}
    end
    |> case do
      {:error, error} ->
        {:error, "Could not store file: #{error}"}

      success_tuple ->
        success_tuple
    end
  end

  @impl Storage
  def copy(%Encapsulation{id: id} = encapsulation, path, opts \\ []) do
    id
    |> File.cp(path)
    |> case do
      :ok -> {:ok, encapsulation |> Map.replace!(:id, path)}
      error_tuple -> error_tuple
    end
  end

  @impl Storage
  def delete(%Encapsulation{id: id}, opts \\ []) when is_binary(id) do
    id
    |> File.rm()
    |> case do
      :ok -> :ok
      {:error, error} -> {:error, "Could not remove file: #{error}"}
    end
  end

  @impl Storage
  def read(%Encapsulation{id: id}, opts \\ []), do: File.read(id)

  defp create_path!(path) do
    path |> Path.dirname() |> File.mkdir_p!()
  end
end
