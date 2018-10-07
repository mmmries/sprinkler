defmodule SprinklerTest do
  use ExUnit.Case
  doctest Sprinkler

  test "knows its own name" do
    assert Sprinkler.name() == "example"
  end

  test "knows its own auth token" do
    assert Sprinkler.auth_token() == ""
  end
end
