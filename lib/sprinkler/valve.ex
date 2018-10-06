defmodule Sprinkler.Valve do
  use GenServer
  @target Mix.Project.config()[:target]
  @registry :valve_registry

  def start_link(valve_init) do
    GenServer.start_link(__MODULE__, valve_init)
  end

  def status(valve), do: GenServer.call({:via, Registry, {@registry, valve}}, :status)
  def turn_off(valve), do: GenServer.call({:via, Registry, {@registry, valve}}, :turn_off)
  def turn_on(valve),  do: GenServer.call({:via, Registry, {@registry, valve}}, :turn_on)

  # init is defined per @target below

  def handle_call(:status, _from, {gpio, status}) do
    {:reply, status, {gpio, status}}
  end

  def handle_call(:turn_on, _from, {gpio, :off}) do
    result = turn_on_pin(gpio)
    Sprinkler.Reporter.nudge()
    {:reply, result, {gpio, :on}}
  end

  def handle_call(:turn_on, _from, {gpio, :on}) do
    {:reply, :ok, {gpio, :on}}
  end

  def handle_call(:turn_off, _from, {gpio, :off}) do
    {:reply, :ok, {gpio, :off}}
  end

  def handle_call(:turn_off, _from, {gpio, :on}) do
    result = turn_off_pin(gpio)
    Sprinkler.Reporter.nudge()
    {:reply, result, {gpio, :off}}
  end

  if @target == "host" do
    def init(%{pin: pin_number, name: name}) do
      Registry.register(@registry, name, name)
      {:ok, {nil, :off}}
    end

    defp turn_on_pin(_), do: :ok
    defp turn_off_pin(_), do: :ok
  else
    alias ElixirALE.GPIO

    def init(%{pin: pin_number, name: name}) do
      {:ok, gpio} = GPIO.start_link(pin_number, :output)
      :ok = GPIO.write(gpio, 1)
      {:ok, {gpio, :off}}
    end

    def turn_on_pin(gpio), do: GPIO.write(gpio, 0)
    def turn_off_pin(gpio), do: GPIO.write(gpio, 1)
  end
end
