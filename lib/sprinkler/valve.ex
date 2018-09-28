defmodule Sprinkler.Valve do
  use GenServer
  alias ElixirALE.GPIO

  def start_link({pin_number, name}) do
    GenServer.start_link(__MODULE__, pin_number, name: name)
  end

  def status(valve), do: GenServer.call(valve, :status)
  def turn_off(valve), do: GenServer.call(valve, :turn_off)
  def turn_on(valve),  do: GenServer.call(valve, :turn_on)

  def init(pin_number) do
    {:ok, gpio} = GPIO.start_link(pin_number, :output)
    :ok = GPIO.write(gpio, 1)
    {:ok, {gpio, :off}}
  end

  def handle_call(:status, _from, {gpio, status}) do
    {:reply, status, {gpio, status}}
  end

  def handle_call(:turn_on, _from, {gpio, :off}) do
    result = GPIO.write(gpio, 0)
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
    result = GPIO.write(gpio, 1)
    Sprinkler.Reporter.nudge()
    {:reply, result, {gpio, :off}}
  end
end
