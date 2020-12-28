defmodule Capsule.Storages.S3 do
  alias Capsule.{Storage, Upload, Encapsulation}

  @behaviour Storage

  alias ExAws.S3, as: Client

  @impl Storage
  def put(upload, opts \\ []) do
    key = Path.join(opts[:prefix] || "/", Upload.name(upload))

    {:ok, contents} = Upload.contents(upload)

    case Client.put_object(config(opts, :bucket), key, contents)
         |> ex_aws_module().request() do
      {:ok, _} ->
        encapsulation = %Encapsulation{
          id: key,
          size: byte_size(contents),
          storage: to_string(__MODULE__)
        }

        {:ok, encapsulation}

      error ->
        handle_error(error)
    end
  end

  @impl Storage
  def copy(%Encapsulation{id: id} = encapsulation, path, opts \\ []) do
    case Client.put_object_copy(config(opts, :bucket), path, config(opts, :bucket), id)
         |> ex_aws_module().request() do
      {:ok, _} ->
        {:ok, %{encapsulation | id: path}}

      error ->
        handle_error(error)
    end
  end

  @impl Storage
  def delete(%Encapsulation{id: id}, opts \\ []) do
    case Client.delete_object(config(opts, :bucket), id)
         |> ex_aws_module().request() do
      {:ok, _} -> :ok
      error -> handle_error(error)
    end
  end

  @impl Storage
  def read(%Encapsulation{id: id}, opts \\ []) do
    case Client.get_object(config(opts, :bucket), id) |> ex_aws_module().request() do
      {:ok, %{body: contents}} -> {:ok, contents}
      error -> handle_error(error)
    end
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
