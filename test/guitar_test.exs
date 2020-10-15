defmodule GuitarTest do
  use ExUnit.Case
  doctest Guitar

  test "greets the world" do
    assert Guitar.hello() == :world
  end
end
