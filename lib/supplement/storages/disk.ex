defmodule Capsule.Storages.Disk do
  alias Capsule.{Storage, Upload}

  @behaviour Storage

  @impl Storage
  def put(upload, opts \\ []) do
    with path <- Path.join(opts[:prefix] || "/", opts[:name] || Upload.name(upload)),
         destination <- path(path, opts),
         true <-
           !File.exists?(destination) || opts[:force] || if(opts[:skip_existing], do: {:ok, destination}) ||
             {:error, "File already exists at #{destination}"},
         :ok <- do_put(opts[:upload_with], upload, destination) do

      {:ok, path}
    end
    |> case do
      {:ok, path} -> {:ok, path}
      {:error, error} -> {:error, "Could not store file: #{error}"}
      other -> {:error, "Could not store file: #{inspect other}"}
    end
  end

  defp do_put(_stream, %struct{} = upload, destination) when struct in [File.Stream, Stream, IO.Stream] do
    create_path!(destination)

    upload
    |> Stream.into(File.stream!(destination))
    |> Stream.run()
  end
  defp do_put(:contents, upload, destination) do
    with {:ok, contents} <- Upload.contents(upload) do
      create_path!(destination)

      File.write(destination, contents)
    end
  end
  defp do_put(_path, upload, destination) do
    path = Upload.path(upload)

    with true <- is_binary(path) and File.exists?(path) do

      create_path!(destination)

      if path == destination do
        do_put(:contents, upload, destination)
      else
        with {:ok, _} <- File.copy(path, destination) do
          :ok
        end
      end

    else 
      _false ->
      do_put(:contents, upload, destination)
    end
  end

  def clone(id, dest_path, opts \\ []) do
    path(dest_path, opts)
    |> create_path!

    path(id, opts)
    |> File.cp(path(dest_path, opts))
    |> case do
      :ok -> {:ok, dest_path}
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
  def stream(path, opts \\ []) do 
    path = path(path, opts)
    if File.exists?(path), do: File.stream!(path, [], 512)
  end

  @impl Storage
  def read(path, opts \\ []), do: path(path, opts) |> File.read()

  @impl Storage
  def url(path, opts \\ []), do: Path.join("/", path(path, opts))

  @impl Storage
  def path(path, opts \\ [])  
  def path(path, opts) when is_binary(path) do 
    opts = config(opts)
    root_dir = Keyword.get(opts, :root_dir)

    if is_nil(root_dir) or String.starts_with?(path, Path.join("/", root_dir)) do
      String.trim(path, "/")
    else
      Path.join(root_dir, path)
    end
  end
  def path(%{} = upload, opts) do 
    Upload.name(upload)
    |> path(opts)
  end

  defp config(opts) do
    Application.get_env(:capsule, __MODULE__, [])
    |> Keyword.merge(opts)
  end
  # defp config(opts, key) do
  #   config(opts)
  #   |> Keyword.fetch!(key)
  # end

  defp create_path!(path) do
    path |> Path.dirname() |> File.mkdir_p!()
  end
end
