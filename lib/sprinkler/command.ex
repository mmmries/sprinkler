defmodule Sprinkler.Command do
  require Logger

  def decode(%{body: json, reply_to: reply_to}) do
    case json |> Jason.decode! |> auth() do
      {:reply, response} ->
        Gnat.pub(:gnat, reply_to, Jason.encode!(response))
      _other -> nil
    end
  end

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

  def process(_) do
    Logger.error("RECEIVED BAD COMMAND #{__MODULE__}")
    {:reply, %{"status" => 400, "message" => "Unrecognized Command"}}
  end
end
