defmodule Capsule.Storages.S3 do
  alias Capsule.{Storage, Upload, Encapsulation}

  @behaviour Storage

  alias ExAws.S3, as: Client

  @impl Storage
  def put(upload, opts \\ []) do
    bucket = Keyword.fetch!(opts, :bucket)

    key = Path.join(opts[:prefix] || "/", Upload.name(upload))

    {:ok, contents} = Upload.contents(upload)

    case Client.put_object(
           bucket,
           key,
           contents,
           Keyword.get(opts, :s3_options, [])
         )
         |> ex_aws_module().request() do
      {:ok, _} ->
        encapsulation = %Encapsulation{
          id: Path.join(bucket, key),
          size: byte_size(contents),
          storage: to_string(__MODULE__)
        }

        {:ok, encapsulation}

      error ->
        handle_error(error)
    end
  end

  @impl Storage
  def copy(%Encapsulation{id: id} = encapsulation, path, _opts \\ []) do
    {bucket, key} = parse_id(id)
    case Client.put_object_copy(bucket, path, bucket, key)
         |> ex_aws_module().request() do
      {:ok, _} ->
        {:ok, %{encapsulation | id: path}}

      error ->
        handle_error(error)
    end
  end

  @impl Storage
  def delete(%Encapsulation{id: id}, _opts \\ []) do
    {bucket, key} = parse_id(id)
    case Client.delete_object(bucket, key)
         |> ex_aws_module().request() do
      {:ok, _} -> :ok
      error -> handle_error(error)
    end
  end

  @impl Storage
  def read(%Encapsulation{id: id}, _opts \\ []) do
    {bucket, key} = parse_id(id)
    case Client.get_object(bucket, key) |> ex_aws_module().request() do
      {:ok, %{body: contents}} -> {:ok, contents}
      error -> handle_error(error)
    end
  end

  defp ex_aws_module() do
    Application.get_env(:capsule, __MODULE__)
    |> Keyword.get(:ex_aws_module, ExAws)
  end

  defp handle_error({:error, error}) do
    {:error, "S3 storage API error: #{error |> inspect()}"}
  end

  defp parse_id(id) do
    [bucket | rest] = Path.split(id)
    {bucket, Path.join(rest)}
  end
end
