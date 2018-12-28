defmodule Sprinkler.Reporter do
  use GenServer
  @idle_timeout 300_000

  def start_link(opts) do
    GenServer.start_link(__MODULE__, nil, opts)
  end

  def nudge(pid \\ __MODULE__) do
    GenServer.cast(pid, :nudge)
  end

  def init(nil) do
    PhoenixChannelClient.join(Sprinkler.Channel)
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

  defp gather_status(name) do
    status = try do
               Sprinkler.Valve.status(name)
             catch :exit, _ ->
               :unknown
             end
    %{"name" => name, "status" => status}
  end

  defp report_status do
    Sprinkler.valves()
    |> Enum.map(&gather_status/1)
    |> send_status
  end

  defp send_status(zones) do
    PhoenixChannelClient.push(Sprinkler.Channel, "zone_status", %{"zones" => zones})
  end
end
