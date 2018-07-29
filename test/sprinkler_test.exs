defmodule SprinklerTest do
  use ExUnit.Case
  doctest Sprinkler

  test "greets the world" do
    assert Sprinkler.hello() == :world
  end
end
