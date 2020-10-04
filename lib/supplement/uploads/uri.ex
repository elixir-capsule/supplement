defimpl Capsule.Upload, for: URI do
  def contents(name) do
    download =
      Task.async(fn ->
        :httpc.request(:get, {name |> URI.to_string() |> String.to_charlist(), []}, [],
          body_format: :binary
        )
      end)

    case download |> Task.await(15_000) do
      {:ok, {{'HTTP/1.1', 200, 'OK'}, _headers, body}} -> {:ok, body}
      {:error, {reason}} -> {:error, reason}
    end
  end

  def name(%{path: path}), do: Path.basename(path)
end
