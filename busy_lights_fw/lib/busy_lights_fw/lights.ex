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
    1..8
    |> Enum.to_list()
    |> Enum.map(fn led -> BusyLightsFw.Blinkt.set_led(led, 0,0,255,0.1) end)

    BusyLightsFw.Blinkt.show()
    {:noreply, %{state | next: nil}}
  end

  def handle_cast(:set_light, %{next: :white} = state) do
    [1,3,6,8]
    |> Enum.map(fn led -> BusyLightsFw.Blinkt.set_led(led, 255,255,255,0.1) end)

    [2,4,5,7]
    |> Enum.map(fn led -> BusyLightsFw.Blinkt.set_led(led, 0, 0, 0, 0.0) end)

    BusyLightsFw.Blinkt.show()
    {:noreply, %{state | next: nil}}
  end

  def handle_cast(:set_light, %{next: :red} = state) do
    1..8
    |> Enum.to_list()
    |> Enum.map(fn led -> BusyLightsFw.Blinkt.set_led(led, 255, 0, 0, 0.5) end)

    BusyLightsFw.Blinkt.show()
    {:noreply, %{state | next: nil}}
  end

  def handle_cast(:set_light, %{next: :yellow} = state) do
    [1,2,3,6,7,8]
    #|> Enum.map(fn led -> BusyLightsFw.Blinkt.set_led(led, 255,255,0,0.5) end)
    |> Enum.map(fn led -> BusyLightsFw.Blinkt.set_led(led, 255,164,0,0.5) end)

    [4,5]
    |> Enum.map(fn led -> BusyLightsFw.Blinkt.set_led(led, 0, 0, 0, 0.0) end)

    BusyLightsFw.Blinkt.show()
    {:noreply, %{state | next: nil}}
  end

  def handle_cast(:set_light, %{next: :green} = state) do
    [1,8]
    |> Enum.map(fn led -> BusyLightsFw.Blinkt.set_led(led, 0, 255, 0, 0.5) end)

    2..7
    |> Enum.to_list()
    |> Enum.map(fn led -> BusyLightsFw.Blinkt.set_led(led, 0, 0, 0, 0.0) end)

    BusyLightsFw.Blinkt.show()
    {:noreply, %{state | next: nil}}
  end

  def handle_cast(:set_light, %{next: :blank} = state) do
    1..8
    |> Enum.to_list()
    |> Enum.map(fn led -> BusyLightsFw.Blinkt.set_led(led, 0, 0, 0, 0.0) end)

    BusyLightsFw.Blinkt.show()
    {:noreply, %{state | next: nil}}
  end
end
