defmodule GarageDoor.Reporter do
  use GenServer
  @idle_timeout 300_000

  def start_link(opts \\ [name: __MODULE__]) do
    GenServer.start_link(__MODULE__, nil, opts)
  end

  def nudge(pid \\ __MODULE__) do
    GenServer.cast(pid, :nudge)
  end

  def init(nil) do
    PhoenixChannelClient.join(GarageDoor.Channel)
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

  defp gather_status(%{name: name}) do
    status = try do
               GarageDoor.status(name)
             catch :exit, _ ->
               :unknown
             end
    %{"name" => name, "status" => status}
  end

  defp report_status do
    GarageDoor.doors()
    |> Enum.map(&gather_status/1)
    |> send_status()
  end

  defp send_status(doors) do
    PhoenixChannelClient.push(GarageDoor.Channel, "door_status", %{"doors" => doors})
  end
end
