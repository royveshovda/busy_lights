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
    bg_color = ""
    status = "Not working"

    socket =
      socket
      |> assign(lights: lights)
      |> assign(nodes: nodes)
      |> assign(color: bg_color)
      |> assign(status: status)
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
  def handle_info({:lights, color}, socket) do
    socket =
      socket
      |> assign(lights: color)
      |> assign(color: get_bg_from_color(color))
      |> assign(status: get_status_from_color(color))
    {:noreply, socket}
  end

  def handle_info({:nodes, nodes, _change}, socket) do
    nodes = Enum.sort(nodes)
    {:noreply, assign(socket, nodes: nodes)}
  end

  def handle_info(_ignore, socket) do
    {:noreply, socket}
  end

  defp get_status_from_color(:red), do: "Meeting"
  defp get_status_from_color(:yellow), do: "Busy"
  defp get_status_from_color(:green), do: "Free"
  defp get_status_from_color(:blank), do: "Not working"

  defp get_bg_from_color(:red), do: "red"
  defp get_bg_from_color(:yellow), do: "yellow"
  defp get_bg_from_color(:green), do: "green"
  defp get_bg_from_color(:blank), do: ""

end
