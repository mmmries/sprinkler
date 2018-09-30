defmodule Sprinkler.Command do
  require Logger

  def decode(%{body: json, reply_to: reply_to}) do
    case json |> Jason.decode! |> process() do
      {:reply, response} ->
        Gnat.pub(:gnat, reply_to, Jason.encode!(response))
      _other -> nil
    end
  end

  def process(%{"type" => "nudge"}) do
    Sprinkler.Reporter.nudge()
    {:reply, %{"status" => 200}}
  end

  def process(_) do
    Logger.error("RECEIVED BAD COMMAND #{__MODULE__}")
    {:reply, %{"status" => 400, "message" => "Unrecognized Error"}}
  end
end
