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
      {Gnat.ConnectionSupervisor, Application.get_env(:sprinkler, :gnat_connection)},
      {Gnat.ConsumerSupervisor, Application.get_env(:sprinkler, :gnat_consumer)},
      {Sprinkler.Reporter, name: Sprinkler.Reporter},
    ]
    valves = Enum.map(Application.get_env(:sprinkler, :valves), fn(%{name: name}=valve_init) ->
      %{id: name, start: {Sprinkler.Valve, :start_link, [valve_init]}}
    end)
    device_children ++ general_behaviors ++ valves
  end

  defp children("host") do
    []
  end

  defp children(_target) do
    [{Sprinkler.Blinky, nil}]
  end
end
