defmodule Sprinkler.NudgeTest do
  use ExUnit.Case

  test "it triggers a publish of current status" do
    # listen for broadcasts
    {:ok, sub} = Gnat.sub(:gnat, self(), "sprinkler.zones.example")
    :ok = Gnat.unsub(:gnat, sub, max_messages: 1)

    cmd = %{"auth_token" => Sprinkler.auth_token(), "type" => "nudge"}
    assert {:reply, %{"status" => 200}} = Sprinkler.Command.auth(cmd)

    assert_receive {:msg, %{topic: "sprinkler.zones.example", body: body}}
    broadcast = Jason.decode!(body)
    assert %{"zones" => _} = broadcast
  end
end
