defmodule SupplementTest do
  use ExUnit.Case
  doctest Supplement

  test "greets the world" do
    assert Supplement.hello() == :world
  end
end
