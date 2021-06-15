defmodule Buttons do
  use GenServer

  require Logger

  @red 26
  @yellow 19
  @green 13
  @black 6

  def start_link(_opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(_opts) do
    {:ok, red_pin} = Circuits.GPIO.open(@red, :input)
    {:ok, yellow_pin} = Circuits.GPIO.open(@yellow, :input)
    {:ok, green_pin} = Circuits.GPIO.open(@green, :input)
    {:ok, black_pin} = Circuits.GPIO.open(@black, :input)

    Circuits.GPIO.set_pull_mode(red_pin, :pullup)
    Circuits.GPIO.set_pull_mode(yellow_pin, :pullup)
    Circuits.GPIO.set_pull_mode(green_pin, :pullup)
    Circuits.GPIO.set_pull_mode(black_pin, :pullup)

    Circuits.GPIO.set_interrupts(red_pin, :falling)
    Circuits.GPIO.set_interrupts(yellow_pin, :falling)
    Circuits.GPIO.set_interrupts(green_pin, :falling)
    Circuits.GPIO.set_interrupts(black_pin, :falling)

    state = %{red_pin: red_pin, yellow_pin: yellow_pin, green_pin: green_pin, black_pin: black_pin}

    {:ok, state}
  end

  def handle_info({:circuits_gpio, @red, _stamp, 0}, state) do
    Logger.info("Red pin falling")
    #Lights.red()
    hub = :hub # TODO: Get from config
    Phoenix.PubSub.broadcast(hub, "lights_update", {:lights, :red})
    {:noreply, state}
  end

  def handle_info({:circuits_gpio, @yellow, _stamp, 0}, state) do
    Logger.info("Yellow pin falling")
    #Lights.yellow()
    hub = :hub # TODO: Get from config
    Phoenix.PubSub.broadcast(hub, "lights_update", {:lights, :yellow})
    {:noreply, state}
  end

  def handle_info({:circuits_gpio, @green, _stamp, 0}, state) do
    Logger.info("Green pin falling")
    #Lights.green()
    hub = :hub # TODO: Get from config
    Phoenix.PubSub.broadcast(hub, "lights_update", {:lights, :green})
    {:noreply, state}
  end

  def handle_info({:circuits_gpio, @black, _stamp, 0}, state) do
    Logger.info("Black pin falling")
    #Lights.blank()
    hub = :hub # TODO: Get from config
    Phoenix.PubSub.broadcast(hub, "lights_update", {:lights, :blank})

    {:noreply, state}
  end

  def handle_info({:circuits_gpio, pin, _stamp, _rising}, state) do
    Logger.info("Pin: #{pin} falling")

    {:noreply, state}
  end
end
