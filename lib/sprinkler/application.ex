defmodule Sprinkler.Application do
  @moduledoc false

  @target Mix.Project.config()[:target]

  use Application

  def start(_type, _args) do
    opts = [strategy: :one_for_one, name: Sprinkler.Supervisor]
    Supervisor.start_link(children(), opts)
  end

  def children do
    device_children = children(@target)
    general_behaviors = [
      {Registry, keys: :unique, name: :valve_registry},
      {DynamicSupervisor, strategy: :one_for_one, name: :scheduler},
      {Sprinkler.Socket, [strategy: :one_for_one, name: Sprinkler.Socket]},
      {Sprinkler.Channel, {[socket: Sprinkler.Socket, topic: "sprinkler"], [name: Sprinkler.Channel]}},
      {GarageDoor.Channel, {[socket: Sprinkler.Socket, topic: "garage_doors"], [name: GarageDoor.Channel]}},
      {Sprinkler.Reporter, name: Sprinkler.Reporter},
      {GarageDoor.Reporter, name: GarageDoor.Reporter},
    ]
    valves = Enum.map(Application.get_env(:sprinkler, :valves), fn(%{name: name}=valve_init) ->
      %{id: name, start: {Sprinkler.Valve, :start_link, [valve_init]}}
    end)
    garage_doors = Enum.map(GarageDoor.doors(), fn(%{name: name}=door) ->
      %{id: name, start: {GarageDoor, :start_link, [door]}}
    end)
    device_children ++ general_behaviors ++ valves ++ garage_doors
  end

  defp children("host") do
    []
  end

  defp children(_target) do
    [{Sprinkler.Blinky, nil}]
  end
end
