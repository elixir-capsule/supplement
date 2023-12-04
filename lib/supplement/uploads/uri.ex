defimpl Capsule.Upload, for: URI do
  def contents(name) do
    download =
      Task.async(fn ->
        :httpc.request(:get, {name |> URI.to_string() |> String.to_charlist(), []}, [],
          body_format: :binary
        )
      end)

    case download |> Task.await(15_000) do
      {:ok, {{'HTTP/1.1', 200, 'OK'}, _headers, body}} ->
        {:ok, body}

      {:ok, {{'HTTP/1.1', code, _}, _headers, _}} ->
        {:error, "Unsuccessful response code: #{code}"}

      {:error, {reason, _}} ->
        {:error, reason}
    end
  end

  def path(_) do
    nil
  end

  def name(%{path: path}), do: Path.basename(path)
end
