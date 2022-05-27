defmodule BusyLightsFw.Lights do
  use GenServer
  require Logger

  def start_link(_opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(_opts) do
    state = %{next: nil}
    Logger.info("Lights server started")
    {:ok, state}
  end

  def blue() do
    Logger.debug("Request BLUE")
    GenServer.cast(__MODULE__, {:request_light, :blue})
  end

  def white() do
    Logger.debug("Request WHITE")
    GenServer.cast(__MODULE__, {:request_light, :white})
  end

  def red() do
    Logger.debug("Request RED")
    GenServer.cast(__MODULE__, {:request_light, :red})
  end

  def yellow() do
    Logger.debug("Request YELLOW")
    GenServer.cast(__MODULE__, {:request_light, :yellow})
  end

  def green() do
    Logger.debug("Request GREEN")
    GenServer.cast(__MODULE__, {:request_light, :green})
  end

  def blank() do
    Logger.debug("Request <BLANK>")
    GenServer.cast(__MODULE__, {:request_light, :blank})
  end

  def handle_cast({:request_light, color}, state) do
    Process.send_after(self(), :process_light, 5)
    {:noreply, %{state | next: color}}
  end

  def handle_info(:process_light, %{next: color} = state) do
    Logger.debug("Set light #{color}")
    do_set_light(color)
    {:noreply, %{state | next: nil}}
  end

  def do_set_light(:nil) do
    Logger.debug("Do nothing")
  end

  def do_set_light(:blue) do
    1..8 |> Enum.to_list() |> Enum.map(fn led -> BusyLightsFw.Blinkt.set_led(led, 0,0,255,0.1) end)
    BusyLightsFw.Blinkt.show()
  end

  def do_set_light(:white) do
    [1,3,6,8] |> Enum.map(fn led -> BusyLightsFw.Blinkt.set_led(led, 255,255,255,0.1) end)
    [2,4,5,7] |> Enum.map(fn led -> BusyLightsFw.Blinkt.set_led(led, 0, 0, 0, 0.0) end)
    BusyLightsFw.Blinkt.show()
  end

  def do_set_light(:red) do
    1..8 |> Enum.to_list() |> Enum.map(fn led -> BusyLightsFw.Blinkt.set_led(led, 255, 0, 0, 0.5) end)
    BusyLightsFw.Blinkt.show()
  end

  def do_set_light(:yellow) do
    [1,2,3,6,7,8] |> Enum.map(fn led -> BusyLightsFw.Blinkt.set_led(led, 255,164,0,0.5) end)
    [4,5] |> Enum.map(fn led -> BusyLightsFw.Blinkt.set_led(led, 0, 0, 0, 0.0) end)
    BusyLightsFw.Blinkt.show()
  end

  def do_set_light(:green) do
    [1,8] |> Enum.map(fn led -> BusyLightsFw.Blinkt.set_led(led, 0, 255, 0, 0.5) end)
    2..7 |> Enum.to_list() |> Enum.map(fn led -> BusyLightsFw.Blinkt.set_led(led, 0, 0, 0, 0.0) end)
    BusyLightsFw.Blinkt.show()
  end

  def do_set_light(:blank) do
    1..8 |> Enum.to_list() |> Enum.map(fn led -> BusyLightsFw.Blinkt.set_led(led, 0, 0, 0, 0.0) end)
    BusyLightsFw.Blinkt.show()
  end
end
