defmodule Sprinkler.Reporter do
  use GenServer
  @idle_timeout 300_000
  @zones [:zone1, :zone2, :zone3, :zone4, :zone5, :zone6, :zone7, :zone8]

  def start_link(opts) do
    GenServer.start_link(__MODULE__, nil, opts)
  end

  def nudge(pid \\ __MODULE__) do
    GenServer.cast(pid, :nudge)
  end

  def init(nil) do
    {:ok, nil, @idle_timeout}
  end

  def handle_cast(:nudge, state) do
    report_status()
    {:noreply, state, @idle_timeout}
  end

  def handle_info(:timeout, state) do
    report_status()
    {:noreply, state, @idle_timeout}
  end

  defp gather_status(zone) do
    status = try do
               Sprinkler.Valve.status(zone)
             catch :exit, _ ->
               :unknown
             end
    %{"name" => zone, "status" => status}
  end

  defp report_status do
    @zones
    |> Enum.map(&gather_status/1)
    |> send_status
  end

  defp send_status(zones) do
    {:ok, msg} = Jason.encode(%{"zones" => zones})
    Gnat.pub(:gnat, "sprinkler.zones.#{Sprinkler.name()}", msg)
  end
end
