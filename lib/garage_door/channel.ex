defmodule GarageDoor.Channel do
  use PhoenixChannelClient
  require Logger

  def handle_in(event, payload, state) do
    Logger.debug("#{__MODULE__} RECEIVED #{event} :: #{inspect payload}")
    {:noreply, state}
  end

  def handle_reply({:timeout, :join}, state) do
    Logger.debug("#{__MODULE__} JOIN TIMEOUT")
    Process.send_after(self(), :rejoin, 5_000)
    {:noreply, state}
  end
  def handle_reply({status, event, _ref}, state) do
    Logger.debug("#{__MODULE__} REPLY #{status} :: #{event}")
    {:noreply, state}
  end
  def handle_reply({status, event, payload, _ref}, state) do
    Logger.debug("#{__MODULE__} REPLY #{status} :: #{event} :: #{inspect payload}")
    {:noreply, state}
  end

  def handle_close(reason, state) do
    Logger.debug("#{__MODULE__} Channel Closed #{inspect reason}")
    Process.send_after(self(), :rejoin, 5_000)
    {:noreply, state}
  end
end
