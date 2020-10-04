defmodule Capsule.Storages.S3 do
  alias Capsule.{Storage, Upload, Encapsulation}

  @behaviour Storage

  alias ExAws.S3, as: Client

  @impl Storage
  def put(upload, opts \\ []) do
    bucket = Keyword.fetch!(config(), :bucket)
    key = Path.join(opts[:prefix] || "/", Upload.name(upload))
    {:ok, contents} = Upload.contents(upload)

    case Client.put_object(bucket, key, contents) |> ExAws.request() do
      {:ok, _} ->
        encapsulation = %Encapsulation{
          id: key,
          size: byte_size(contents),
          storage: __MODULE__
        }

        {:ok, encapsulation}

      error ->
        handle_error(error)
    end
  end

  @impl Storage
  def copy(%Encapsulation{id: id} = encapsulation, path) do
    bucket = Keyword.fetch!(config(), :bucket)

    case Client.put_object_copy(bucket, path, bucket, id)
         |> ExAws.request() do
      {:ok, _} ->
        {:ok, %{encapsulation | id: path}}

      error ->
        handle_error(error)
    end
  end

  @impl Storage
  def delete(%Encapsulation{id: id}) do
    bucket = Keyword.fetch!(config(), :bucket)

    case Client.delete_object(bucket, id)
         |> ExAws.request() do
      {:ok, _} -> {:ok, nil}
      error -> handle_error(error)
    end
  end

  @impl Storage
  def open(%Encapsulation{id: id}) do
    bucket = Keyword.fetch!(config(), :bucket)

    case Client.get_object(bucket, id) |> ExAws.request() do
      {:ok, %{body: contents}} -> {:ok, contents}
      error -> handle_error(error)
    end
  end

  defp config(), do: Application.fetch_env!(:capsule, __MODULE__)

  defp handle_error({:error, error}) do
    {:error, "S3 storage API error: #{error |> inspect()}"}
  end
end
