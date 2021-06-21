defmodule BusyLightsUi.FakeLights do
  require Logger

  def blue() do
    Logger.debug("Show BLUE")
  end

  def white() do
    Logger.debug("Show WHITE")
  end

  def red() do
    Logger.debug("Show RED")
  end

  def yellow() do
    Logger.debug("Show YELLOW")
  end

  def green() do
    Logger.debug("Show GREEN")
  end

  def blank() do
    Logger.debug("Show <BLANK>")
  end
end
