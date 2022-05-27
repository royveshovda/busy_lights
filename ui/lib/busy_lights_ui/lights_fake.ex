defmodule BusyLightsUi.FakeLights do
  use GenServer
  require Logger

  # To simulate hardware delay
  @sleeptime_in_ms 5

  def start_link(_opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(_opts) do
    state = %{next: nil}
    Logger.info("Fake Lights server started")
    {:ok, state}
  end

  def set_color(color) do
    Logger.debug("Request (#{color})")
    GenServer.call(__MODULE__, {:request_light, color})
  end

  def handle_call({:request_light, color}, _from, state) do
    GenServer.cast(__MODULE__, :set_light)
    {:reply, :ok, %{state | next: color}}
  end

  def handle_cast(:set_light, %{next: :nil} = state) do
    Logger.debug("Do nothing")
    {:noreply, state}
  end

  def handle_cast(:set_light, %{next: color} = state) do
    Logger.debug("Show (#{color})")
    :timer.sleep(@sleeptime_in_ms)
    {:noreply, %{state | next: nil}}
  end
end
