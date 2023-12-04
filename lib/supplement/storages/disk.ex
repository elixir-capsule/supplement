defmodule Capsule.Storages.Disk do
  alias Capsule.{Storage, Upload}

  @behaviour Storage

  @impl Storage
  def put(upload, opts \\ []) do
    with path <- Path.join(opts[:prefix] || "/", Upload.name(upload)),
         destination <- path(path, opts),
         true <-
           !File.exists?(destination) || opts[:force] ||
             {:error, "File already exists at upload destination"},
         :ok <- do_put(opts[:upload_with], upload, destination) do

      {:ok, path}
    end
    |> case do
      {:ok, path} -> {:ok, path}
      {:error, error} -> {:error, "Could not store file: #{error}"}
      other -> {:error, "Could not store file: #{inspect other}"}
    end
  end

  defp do_put(:contents, upload, destination) do
    with {:ok, contents} <- Upload.contents(upload) do
      create_path!(destination)

      File.write(destination, contents)
    end
  end
  defp do_put(_path, upload, destination) do
    with {:ok, path} <- Upload.path(upload) do
      create_path!(destination)

      if path == destination do
        do_put(:contents, upload, destination)
      else
        with {:ok, _} <- File.copy(path, destination) do
          :ok
        end
      end

    else nil ->
      do_put(:contents, upload, destination)
    end
  end

  def copy(id, path, opts \\ []) do
    path(path, opts)
    |> create_path!

    path(id, opts)
    |> File.cp(path(path, opts))
    |> case do
      :ok -> {:ok, path}
      error_tuple -> error_tuple
    end
  end

  @impl Storage
  def delete(id, opts \\ []) when is_binary(id) do
    path(id, opts)
    |> File.rm()
    |> case do
      :ok -> :ok
      {:error, error} -> {:error, "Could not remove file: #{error}"}
    end
  end

  @impl Storage
  def read(path, opts \\ []), do: path(path, opts) |> File.read()

  @impl Storage
  def url(path, opts \\ []), do: Path.join("/", path(path, opts))

  @impl Storage
  def path(path, opts \\ []), do: config(opts, :root_dir)
    |> Path.join(path)

  defp config(opts, key) do
    Application.fetch_env!(:capsule, __MODULE__)
    |> Keyword.merge(opts)
    |> Keyword.fetch!(key)
  end

  defp create_path!(path) do
    path |> Path.dirname() |> File.mkdir_p!()
  end
end
