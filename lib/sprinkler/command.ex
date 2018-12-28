defmodule Sprinkler.Command do
  require Logger

  def auth(%{"auth_token" => token}=command) do
    if token == Sprinkler.auth_token() do
      process(command)
    else
      Logger.error("AUTH ERROR")
      {:reply, %{"status" => 403, "message" => "Invalid Auth Token"}}
    end
  end
  def auth(_) do
    {:reply, %{"status" => 403, "message" => "No auth_token provided"}}
  end

  def process(%{"type" => "nudge"}) do
    Sprinkler.Reporter.nudge()
    {:reply, %{"status" => 200}}
  end
  def process(%{"type" => "turn_off", "zone" => zone}) do
    :ok = Sprinkler.Valve.turn_off(zone)
    {:reply, %{"status" => 200}}
  end
  def process(%{"type" => "turn_on", "zone" => zone}) do
    :ok = Sprinkler.Valve.turn_on(zone)
    {:reply, %{"status" => 200}}
  end
  def process(_) do
    Logger.error("RECEIVED BAD COMMAND #{__MODULE__}")
    {:reply, %{"status" => 400, "message" => "Unrecognized Command"}}
  end
end
