defmodule BusyLightsUi.FakeLights do
  use GenServer
  require Logger

  # To simulate hardware delay
  @sleeptime_in_ms 5000

  def start_link(_opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(_opts) do
    state = %{next: nil}
    Logger.info("Fake Lights server started")
    {:ok, state}
  end

  def blue() do
    Logger.debug("Request BLUE")
    GenServer.call(__MODULE__, {:request_light, :blue})
  end

  def white() do
    Logger.debug("Request WHITE")
    GenServer.call(__MODULE__, {:request_light, :white})
  end

  def red() do
    Logger.debug("Request RED")
    GenServer.call(__MODULE__, {:request_light, :red})
  end

  def yellow() do
    Logger.debug("Request YELLOW")
    GenServer.call(__MODULE__, {:request_light, :yellow})
  end

  def green() do
    Logger.debug("Request GREEN")
    GenServer.call(__MODULE__, {:request_light, :green})
  end

  def blank() do
    Logger.debug("Request <BLANK>")
    GenServer.call(__MODULE__, {:request_light, :blank})
  end

  def handle_call({:request_light, color}, _from, state) do
    GenServer.cast(__MODULE__, :set_light)
    {:reply, :ok, %{state | next: color}}
  end

  def handle_cast(:set_light, %{next: :nil} = state) do
    Logger.debug("Do nothing")
    {:noreply, state}
  end

  def handle_cast(:set_light, %{next: :blue} = state) do
    Logger.debug("Show BLUE")
    :timer.sleep(@sleeptime_in_ms)
    {:noreply, %{state | next: nil}}
  end

  def handle_cast(:set_light, %{next: :white} = state) do
    Logger.debug("Show WHITE")
    :timer.sleep(@sleeptime_in_ms)
    {:noreply, %{state | next: nil}}
  end

  def handle_cast(:set_light, %{next: :red} = state) do
    Logger.debug("Show RED")
    :timer.sleep(@sleeptime_in_ms)
    {:noreply, %{state | next: nil}}
  end

  def handle_cast(:set_light, %{next: :yellow} = state) do
    Logger.debug("Show YELLOW")
    :timer.sleep(@sleeptime_in_ms)
    {:noreply, %{state | next: nil}}
  end

  def handle_cast(:set_light, %{next: :green} = state) do
    Logger.debug("Show GREEN")
    :timer.sleep(@sleeptime_in_ms)
    {:noreply, %{state | next: nil}}
  end

  def handle_cast(:set_light, %{next: :blank} = state) do
    Logger.debug("Show <BLANK>")
    :timer.sleep(@sleeptime_in_ms)
    {:noreply, %{state | next: nil}}
  end
end
