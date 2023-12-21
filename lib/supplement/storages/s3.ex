defmodule Capsule.Storages.S3 do
  alias Capsule.{Storage, Upload}

  @behaviour Storage

  alias ExAws.S3, as: Client

  @impl Storage
  def put(upload, opts \\ []) do
    key = Path.join(opts[:prefix] || "/", Upload.name(upload))

    {:ok, contents} = Upload.contents(upload)

    case Client.put_object(
           config(opts, :bucket),
           key,
           contents,
           Keyword.get(opts, :s3_options, [])
         )
         |> ex_aws_module().request() do
      {:ok, _} -> {:ok, key}
      error -> handle_error(error)
    end
  end

  @impl Storage
  def delete(id, opts \\ []) do
    case Client.delete_object(config(opts, :bucket), id)
         |> ex_aws_module().request() do
      {:ok, _} -> :ok
      error -> handle_error(error)
    end
  end

  @impl Storage
  def read(id, opts \\ []) do
    case Client.get_object(config(opts, :bucket), id) |> ex_aws_module().request() do
      {:ok, %{body: contents}} -> {:ok, contents}
      error -> handle_error(error)
    end
  end

  @impl Storage
  def stream!(id, opts \\ []) do
    opts
    |> config(:bucket)
    |> Client.download_file(id, :memory)
    |> ex_aws_module().stream!()
  end

  defp config(opts, key) do
    Application.fetch_env!(:capsule, __MODULE__)
    |> Keyword.merge(opts)
    |> Keyword.fetch!(key)
  end

  defp ex_aws_module() do
    Application.get_env(:capsule, __MODULE__)
    |> Keyword.get(:ex_aws_module, ExAws)
  end

  defp handle_error({:error, error}) do
    {:error, "S3 storage API error: #{error |> inspect()}"}
  end
end
