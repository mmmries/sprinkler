defmodule Sprinkler do
  def auth_token do
    Application.get_env(:sprinkler, :auth_token)
  end

  # Example of scheduling a zone to turn on and off
  # DynamicSupervisor.start_child(:scheduler, %{ id: "wat", start: {SchedEx, :run_every, [Sprinkler.Valve, :turn_off, [:zone8],  "0 30 9 * * *"]} })
  # DynamicSupervisor.start_child(:scheduler, %{ id: "wat", start: {SchedEx, :run_every, [Sprinkler.Valve, :turn_off, [:zone8],  "0 45 9 * * *"]} })

  def clear_schedule do
    DynamicSupervisor.which_children(:scheduler)
    |> Enum.map(&( elem(&1, 1) ))
    |> Enum.each(fn(pid) -> DynamicSupervisor.terminate_child(:scheduler, pid) end)
  end

  def turn_on_all do
    valves() |> Enum.each(&( Sprinkler.Valve.turn_on(&1) ))
  end

  def turn_off_all do
    valves() |> Enum.each(&( Sprinkler.Valve.turn_off(&1) ))
  end

  def valves do
    Application.get_env(:sprinkler, :valves)
    |> Enum.map(&( Map.get(&1, :name) ))
  end
end
