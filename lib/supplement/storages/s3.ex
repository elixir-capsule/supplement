defmodule Capsule.Storages.S3 do
  alias Capsule.{Storage, Upload, Locator}

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
      {:ok, _} ->
        locator = %Locator{
          id: key,
          storage: to_string(__MODULE__)
        }

        {:ok, locator}

      error ->
        handle_error(error)
    end
  end

  @impl Storage
  def copy(%Locator{id: id} = locator, path, opts \\ []) do
    case Client.put_object_copy(config(opts, :bucket), path, config(opts, :bucket), id)
         |> ex_aws_module().request() do
      {:ok, _} ->
        {:ok, %{locator | id: path}}

      error ->
        handle_error(error)
    end
  end

  @impl Storage
  def delete(%Locator{id: id}, opts \\ []) do
    case Client.delete_object(config(opts, :bucket), id)
         |> ex_aws_module().request() do
      {:ok, _} -> :ok
      error -> handle_error(error)
    end
  end

  @impl Storage
  def read(%Locator{id: id}, opts \\ []) do
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
