defmodule Lights do
  def blue() do
    1..8
    |> Enum.to_list()
    |> Enum.map(fn led -> Blinkt.set_led(led, 0,0,255,0.1) end)

    Blinkt.show()
  end

  def white() do
    [1,3,6,8]
    |> Enum.map(fn led -> Blinkt.set_led(led, 255,255,255,0.1) end)

    [2,4,5,7]
    |> Enum.map(fn led -> Blinkt.set_led(led, 0, 0, 0, 0.0) end)

    Blinkt.show()
  end

  def red() do
    1..8
    |> Enum.to_list()
    |> Enum.map(fn led -> Blinkt.set_led(led, 255, 0, 0, 0.5) end)

    Blinkt.show()
  end

  def yellow() do
    [1,2,3,6,7,8]
    #|> Enum.map(fn led -> Blinkt.set_led(led, 255,255,0,0.5) end)
    |> Enum.map(fn led -> Blinkt.set_led(led, 255,164,0,0.5) end)

    [4,5]
    |> Enum.map(fn led -> Blinkt.set_led(led, 0, 0, 0, 0.0) end)

    Blinkt.show()
  end

  def green() do
    [1,8]
    |> Enum.map(fn led -> Blinkt.set_led(led, 0, 255, 0, 0.5) end)

    2..7
    |> Enum.to_list()
    |> Enum.map(fn led -> Blinkt.set_led(led, 0, 0, 0, 0.0) end)

    Blinkt.show()
  end

  def blank() do
    1..8
    |> Enum.to_list()
    |> Enum.map(fn led -> Blinkt.set_led(led, 0, 0, 0, 0.0) end)

    Blinkt.show()
  end
end
