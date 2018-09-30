defmodule Sprinkler do
  @zones [:zone1, :zone2, :zone3, :zone4, :zone5, :zone6, :zone7, :zone8]

  def name do
    Application.get_env(:sprinkler, :auth) |> Map.get(:name)
  end

  def auth_token do
    Application.get_env(:sprinkler, :auth) |> Map.get(:auth_token)
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
    @zones |> Enum.each(&( Sprinkler.Valve.turn_on(&1) ))
  end

  def turn_off_all do
    @zones |> Enum.each(&( Sprinkler.Valve.turn_off(&1) ))
  end
end
