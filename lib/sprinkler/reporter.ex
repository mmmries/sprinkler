defmodule Sprinkler.Reporter do
  use GenServer
  @idle_timeout 2_000
  @zones [:zone1, :zone2, :zone3, :zone4, :zone5, :zone6, :zone7, :zone8]

  def start_link(opts) do
    GenServer.start_link(__MODULE__, nil, opts)
  end

  def init(nil) do
    Sprinkler.Channel.join()
    {:ok, nil, @idle_timeout}
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
    Sprinkler.Channel.push("zone_status", %{"zones" => zones})
  end
end
