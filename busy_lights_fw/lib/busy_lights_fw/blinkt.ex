defmodule Blinkt do
  #use Agent
  use GenServer
  use Bitwise
  alias Circuits.GPIO

  require Logger

  # The DAT-pin is pin 23
  @dat 23
  # The CLK-pin is pin 24
  @clk 24

  @type led_num :: integer()
  @type red :: byte()
  @type green :: byte()
  @type blue :: byte()
  @type brightness :: float()
  @type colours :: tuple()
  @type led_array :: map()

  @sleeptime 1

  def start_link(_opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(_opts) do
    leds = %{
            # led_number: {red, green, blue, brightness (between 0.0 and 1.0)}
            1 => {0, 0, 0, 0},
            2 => {0, 0, 0, 0},
            3 => {0, 0, 0, 0},
            4 => {0, 0, 0, 0},
            5 => {0, 0, 0, 0},
            6 => {0, 0, 0, 0},
            7 => {0, 0, 0, 0},
            8 => {0, 0, 0, 0}
          }
    {:ok, dat_pin} = GPIO.open(@dat, :output)
    {:ok, clk_pin} = GPIO.open(@clk, :output)
    state = %{dat: dat_pin, clk: clk_pin, leds: leds}

    {:ok, state}
  end

  @spec set_led(led_num(), red(), green(), blue(), brightness()) :: :ok
  def set_led(idx, r, g, b, l)
    when is_float(l) and l >= 0.0 and l <= 1.0 and
         is_integer(r) and r >= 0 and r <= 255 and
         is_integer(g) and g >= 0 and g <= 255 and
         is_integer(b) and b >= 0 and b <= 255 and
         is_integer(idx) and idx > 0 and idx <= 8 do

    GenServer.call(__MODULE__, {:set_led, idx, r, g, b, l})
  end

  def set_led(led_num, r, g, b, l) do
    raise "Values for LED #{led_num} out of range:" <>
          " red: #{r}, green: #{g}, blue: #{b}, brightness: #{l}"
  end

  def clear() do
    GenServer.call(__MODULE__, :clear)
  end

  def show() do
    GenServer.call(__MODULE__, :show)
  end

  def handle_call({:set_led, idx, r, g, b, l}, _from, %{leds: leds} = state) do
    leds = Map.put(leds, idx, {r, g, b, l})
    {:reply, :ok, %{state | leds: leds}}
  end

  def handle_call(:show, _from, %{dat: dat_pin, clk: clk_pin, leds: leds} = state) do
    _show(dat_pin, clk_pin, leds)
    {:reply, :ok, state}
  end

  def handle_call(:clear, _from, %{dat: dat_pin, clk: clk_pin} = state) do
    leds = %{
            1 => {0, 0, 0, 0},
            2 => {0, 0, 0, 0},
            3 => {0, 0, 0, 0},
            4 => {0, 0, 0, 0},
            5 => {0, 0, 0, 0},
            6 => {0, 0, 0, 0},
            7 => {0, 0, 0, 0},
            8 => {0, 0, 0, 0}
          }
    _show(dat_pin, clk_pin, leds)
    {:reply, :ok, %{state | leds: leds}}
  end

  defp _show(dat_pin, clk_pin, leds) do
    start_of_write(dat_pin, clk_pin)
    for led <- 1..8 do
      {r, g, b, l} = Map.get(leds, led)
      brightness = Kernel.trunc(31.0 * l) &&& 0b11111
      _write_byte(0b11100000 ||| brightness, dat_pin, clk_pin)
      _write_byte(b, dat_pin, clk_pin)
      _write_byte(g, dat_pin, clk_pin)
      _write_byte(r, dat_pin, clk_pin)
    end

    end_of_write(dat_pin, clk_pin)
    :ok
  end

  defp start_of_write(dat_pin, clk_pin) do
    GPIO.write(dat_pin, 0)
    for _ <- 1..32, do: _pulse_gpio_pin(clk_pin)
    :ok
  end

  defp end_of_write(dat_pin, clk_pin) do
    GPIO.write(dat_pin, 0)
    for _ <- 1..36, do: _pulse_gpio_pin(clk_pin)
    :ok
  end

  defp _write_byte(byte, dat_pin, clk_pin) do
    for <<bit::size(1) <- <<byte>> >> do
      _write_bit(bit, dat_pin, clk_pin)
    end
  end

  defp _write_bit(bit, dat_pin, clk_pin) do
    GPIO.write(dat_pin, bit)
    _pulse_gpio_pin(clk_pin)
  end

  defp _pulse_gpio_pin(p) do
    GPIO.write(p, 1)
    :timer.sleep(@sleeptime)
    GPIO.write(p, 0)
    :ok
  end
end
