defimpl Capsule.Upload, for: File.Stream do

  def path(%{path: path}) when is_binary(path) do
    case File.exists?(path) do
      false -> nil
      true -> path
    end
  end
  
  def contents(%{} = stream) do
    stream 
  end

  def name(%{path: path}), do: path
end
defimpl Capsule.Upload, for: Stream do

  def path(_) do
    nil
  end
  
  def contents(%{} = stream) do
    stream 
  end

  def name(_), do: nil
end
