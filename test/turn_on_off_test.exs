defmodule Sprinkler.TurnOnOffTest do
  use ExUnit.Case

  test "turning on/off zones" do
    assert Sprinkler.Valve.status("zone1") == :off

    cmd = %{"auth_token" => Sprinkler.auth_token(), "type" => "turn_on", "zone" => "zone1"}
    assert {:reply, %{"status" => 200}} = Sprinkler.Command.auth(cmd)

    assert Sprinkler.Valve.status("zone1") == :on

    cmd = %{"auth_token" => Sprinkler.auth_token(), "type" => "turn_off", "zone" => "zone1"}
    assert {:reply, %{"status" => 200}} = Sprinkler.Command.auth(cmd)

    assert Sprinkler.Valve.status("zone1") == :off
  end
end
