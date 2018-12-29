defmodule GarageDoor do
  use GenServer
  @target Mix.Project.config()[:target]
  @registry :valve_registry

  def start_link(door) do
    GenServer.start_link(__MODULE__, door)
  end

  @spec doors() :: list(%{name: String.t(), sensor_pin: non_neg_integer()})
  def doors do
    Application.get_env(:sprinkler, :garage_doors)
  end

  def status(name) do
    GenServer.call({:via, Registry, {@registry, name}}, :status)
  end

  @impl GenServer
  def handle_info({:gpio_interrupt, _pin, _rising_or_falling}, state) do
    GarageDoor.Reporter.nudge()
    {:noreply, state}
  end
  def handle_info(other, state) do
    require Logger
    Logger.error("#{__MODULE__} received unexpected message #{inspect(other)}")
    {:noreply, state}
  end

  if @target == "host" do
    @impl GenServer
    def init(%{name: name}) do
      Registry.register(@registry, name, name)
      {:ok, %{status: :closed}}
    end

    @impl GenServer
    def handle_call(:status, _from, %{status: status}=state) do
      {:reply, {:ok, status}, state}
    end
    def handle_call(:toggle, _from, %{status: status}=state) do
      status = case status do
        :closed -> :open
        :open -> :closed
      end
      {:reply, {:ok, status}, %{state | status: status}}
    end
  else
    alias ElixirALE.GPIO

    @impl GenServer
    def init(%{sensor_pin: sensor_pin, name: name}) do
      Registry.register(@registry, name, name)
      {:ok, sensor} = GPIO.start_link(sensor_pin, :input)
      GPIO.set_int(sensor, :both)
      {:ok, %{sensor: sensor}}
    end

    @impl GenServer
    def handle_call(:status, _from, %{sensor: sensor}=state) do
      status = sensor |> GPIO.read() |> gpio_to_status()
      {:reply, {:ok, status}, state}
    end

    defp gpio_to_status(0), do: :closed
    defp gpio_to_status(1), do: :open
  end
end
