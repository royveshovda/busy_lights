defmodule BusyLightsUiWeb.PageLive do
  use BusyLightsUiWeb, :live_view

  require Logger

  @impl true
  def mount(_params, _session, socket) do
    lights =
      case connected?(socket) do
        true ->
          Phoenix.PubSub.subscribe(BusyLightsUi.PubSub, "lights_update")
          BusyLightsUi.LightKeeper.get_light
        _ -> :blank # default value
      end

    socket =
      socket
      |> assign(lights: lights)
    {:ok, socket}
  end

  @impl true
  def handle_event("red_button", _value, socket) do
    Logger.debug("Button pressed: RED")
    Phoenix.PubSub.broadcast(BusyLightsUi.PubSub, "lights_update", {:lights, :red})
    {:noreply, socket}
  end

  def handle_event("yellow_button", _value, socket) do
    Logger.debug("Button pressed: YELLOW")
    Phoenix.PubSub.broadcast(BusyLightsUi.PubSub, "lights_update", {:lights, :yellow})
    {:noreply, socket}
  end

  def handle_event("green_button", _value, socket) do
    Logger.debug("Button pressed: GREEN")
    Phoenix.PubSub.broadcast(BusyLightsUi.PubSub, "lights_update", {:lights, :green})
    {:noreply, socket}
  end

  def handle_event("blank_button", _value, socket) do
    Logger.debug("Button pressed: BLANK")
    Phoenix.PubSub.broadcast(BusyLightsUi.PubSub, "lights_update", {:lights, :blank})
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

  def handle_info(_ignore, socket) do
    {:noreply, socket}
  end
end
