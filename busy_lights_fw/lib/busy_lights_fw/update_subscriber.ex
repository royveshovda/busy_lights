defmodule BusyLightsFw.UpdateSubscriber do
  use GenServer

  require Logger

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    Phoenix.PubSub.subscribe(:hub, "lights_update")
    {:ok, %{}}
  end

  def handle_info({:lights, :red}, state) do
    Logger.info("Got Red")
    Lights.red()
    {:noreply, state}
  end

  def handle_info({:lights, :yellow}, state) do
    Logger.info("Got Yellow")
    Lights.yellow()
    {:noreply, state}
  end

  def handle_info({:lights, :green}, state) do
    Logger.info("Got Green")
    Lights.green()
    {:noreply, state}
  end

  def handle_info({:lights, :blank}, state) do
    Logger.info("Got Blank")
    Lights.blank()
    {:noreply, state}
  end
end
