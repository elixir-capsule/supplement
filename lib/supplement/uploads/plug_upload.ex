defimpl Capsule.Upload, for: Plug.Upload do
  def contents(%{path: path}) do
    case File.read(path) do
      {:error, reason} -> {:error, "Could not read path: #{reason}"}
      success_tuple -> success_tuple
    end
  end

  def name(%{filename: name}), do: name
end
