defmodule Capsule.Storages.S3 do
  alias Capsule.{Storage, Upload}

  @behaviour Storage

  alias ExAws.S3, as: Client

  @impl Storage
  def put(upload, opts \\ []) do
    key = Path.join(opts[:prefix] || "/", Upload.name(upload))

    case do_put(opts[:upload_with], upload, key, opts) do
      {:ok, _} -> {:ok, key}
      error -> handle_error(error)
    end
  end

  def clone(source_id, dest_path, opts \\ []) do
    opts = config(opts)
    default_bucket = Keyword.get(opts, :bucket)

    case Client.put_object_copy(
          Keyword.get(opts, :dest_bucket) || default_bucket, 
          dest_path, 
          Keyword.get(opts, :source_bucket) || default_bucket, 
          source_id
         )
         |> ex_aws_module().request(opts) do
      {:ok, _} -> {:ok, dest_path}
      error -> handle_error(error)
    end
  end

  @impl Storage
  def delete(id, opts \\ []) do
    case Client.delete_object(config(opts, :bucket), id)
         |> ex_aws_module().request(opts) do
      {:ok, _} -> :ok
      error -> handle_error(error)
    end
  end

  @impl Storage
  def stream(id, opts \\ []) do
    Client.download_file(config(opts, :bucket), id, :memory)
    |> ex_aws_module().stream!()
  end

  @impl Storage
  def read(id, opts \\ []) do
    case Client.get_object(config(opts, :bucket), id) |> ex_aws_module().request(opts) do
      {:ok, %{body: contents}} -> {:ok, contents}
      error -> handle_error(error)
    end
  end

  @impl Storage
  def url(path, opts \\ []) do
    opts = config(opts)
    case ExAws.Config.new(:s3, opts)
         |> Client.presigned_url(:get, Keyword.fetch!(opts, :bucket), path, opts) do
      {:ok, url} -> {:ok, url}
      error -> handle_error(error)
    end
  end

  @impl Storage
  def path(_path, _opts \\ []), do: nil
  

  defp do_put(:contents, upload, key, opts) do
    with {:ok, contents} <- Upload.contents(upload) do
      Client.put_object(
        config(opts, :bucket),
        key,
        contents,
        Keyword.get(opts, :s3_options) || opts
      )
      |> ex_aws_module().request(opts)
    end
  end
  defp do_put(_stream, upload, key, opts) do
    with path when is_binary(path) <- Upload.path(upload) do
      path
      |> Client.Upload.stream_file()
      |> Client.upload(
        config(opts, :bucket), 
        key, 
        Keyword.get(opts, :s3_options) || opts
      )
      |> ex_aws_module().request(opts)
    else nil ->
      do_put(:contents, upload, key, opts)
    end
  end

  defp config(opts) do
    Application.get_env(:capsule, __MODULE__, [])
    |> Keyword.merge(opts)
  end
  defp config(opts, key) do
    config(opts)
    |> Keyword.fetch!(key)
  end

  defp ex_aws_module() do
    Application.get_env(:capsule, __MODULE__, [])
    |> Keyword.get(:ex_aws_module, ExAws)
  end

  defp handle_error({:error, error}) do
    {:error, "S3 storage API error: #{error |> inspect()}"}
  end
end
