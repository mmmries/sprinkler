defmodule Sprinkler.Application do
  @moduledoc false

  @target Mix.Project.config()[:target]

  use Application

  def start(_type, _args) do
    opts = [strategy: :one_for_one, name: Sprinkler.Supervisor]
    Supervisor.start_link(children(), opts)
  end

  def children do
    list = children(@target)
    [ {DynamicSupervisor, strategy: :one_for_one, name: :scheduler} | list ]
  end

  def children("host") do
    []
  end

  def children(_target) do
    import Supervisor.Spec
    [
      {Sprinkler.Blinky, nil},
      worker(Sprinkler.Valve, [{4,  :zone1}], id: :zone1),
      worker(Sprinkler.Valve, [{17, :zone2}], id: :zone2),
      worker(Sprinkler.Valve, [{18, :zone3}], id: :zone3),
      worker(Sprinkler.Valve, [{27, :zone4}], id: :zone4),
      worker(Sprinkler.Valve, [{22, :zone5}], id: :zone5),
      worker(Sprinkler.Valve, [{23, :zone6}], id: :zone6),
      worker(Sprinkler.Valve, [{24, :zone7}], id: :zone7),
      worker(Sprinkler.Valve, [{25, :zone8}], id: :zone8),
    ]
  end
end
