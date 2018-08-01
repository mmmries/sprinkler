defmodule Sprinkler.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  @target Mix.Project.config()[:target]

  use Application

  def start(_type, _args) do
    opts = [strategy: :one_for_one, name: Sprinkler.Supervisor]
    Supervisor.start_link(children(@target), opts)
  end

  # List all child processes to be supervised
  def children("host") do
    [
      # Starts a worker by calling: Sprinkler.Worker.start_link(arg)
      # {Sprinkler.Worker, arg},
    ]
  end

  def children(_target) do
    [
      {Sprinkler.Blinky, nil},
      {Sprinkler.Valve, {4, :zone1}},
    ]
  end
end
