defmodule BusyLightsUiWeb.PageLive do
  use BusyLightsUiWeb, :live_view

  require Logger

  @impl true
  def mount(_params, _session, socket) do
    lights =
      case connected?(socket) do
        true ->
          Phoenix.PubSub.subscribe(BusyLightsUi.PubSub, "ui_updates")
          BusyLightsUi.LightKeeper.get_light
        _ -> :blank # default value
      end

    nodes = []

    socket =
      socket
      |> assign(lights: lights)
      |> assign(nodes: nodes)
    {:ok, socket}
  end

  @impl true
  def handle_event("red_button", _value, socket) do
    Logger.debug("Button pressed: RED")
    BusyLightsUi.LightKeeper.publish_red()
    {:noreply, socket}
  end

  def handle_event("yellow_button", _value, socket) do
    Logger.debug("Button pressed: YELLOW")
    BusyLightsUi.LightKeeper.publish_yellow()
    {:noreply, socket}
  end

  def handle_event("green_button", _value, socket) do
    Logger.debug("Button pressed: GREEN")
    BusyLightsUi.LightKeeper.publish_green()
    {:noreply, socket}
  end

  def handle_event("blank_button", _value, socket) do
    Logger.debug("Button pressed: BLANK")
    BusyLightsUi.LightKeeper.publish_blank()
    {:noreply, socket}
  end

  @impl true
  def handle_info({:lights, :red}, socket) do
    {:noreply, assign(socket, lights: :red)}
  end

  def handle_info({:lights, :yellow}, socket) do
    {:noreply, assign(socket, lights: :yellow)}
  end

  def handle_info({:lights, :green}, socket) do
    {:noreply, assign(socket, lights: :green)}
  end

  def handle_info({:lights, :blank}, socket) do
    {:noreply, assign(socket, lights: :blank)}
  end

  def handle_info({:nodes, nodes, _change}, socket) do
    nodes = Enum.sort(nodes)
    {:noreply, assign(socket, nodes: nodes)}
  end

  def handle_info(_ignore, socket) do
    {:noreply, socket}
  end
end
