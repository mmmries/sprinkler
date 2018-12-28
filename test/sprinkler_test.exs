defmodule SprinklerTest do
  use ExUnit.Case
  doctest Sprinkler

  test "knows its own auth token" do
    assert Sprinkler.auth_token() == ""
  end
end
