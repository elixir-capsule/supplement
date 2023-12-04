defmodule Capsule.MockUpload do
  defstruct content: "Hi, I'm a file", name: "hi", path: "LICENSE"

  defimpl Capsule.Upload do
    def contents(mock), do: {:ok, mock.content}

    def path(mock), do: {:ok, mock.path}

    def name(mock), do: mock.name
  end
end
