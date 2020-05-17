defmodule BusyLightsUiWeb.PageLive do
  use BusyLightsUiWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, query: "", results: %{})}
  end

  @impl true
  def handle_event("red_button", _value, socket) do
    IO.puts("Red")

    hub = :hub # TODO: Get from config
    #hub = BusyLightsUi.PubSub

    Phoenix.PubSub.broadcast(hub, "lights_update", {:lights, :red})
    {:noreply, socket}
  end

  def handle_event("yellow_button", _value, socket) do
    IO.puts("Yellow")

    hub = :hub # TODO: Get from config

    Phoenix.PubSub.broadcast(hub, "lights_update", {:lights, :yellow})
    {:noreply, socket}
  end

  def handle_event("green_button", _value, socket) do
    IO.puts("Green")

    hub = :hub # TODO: Get from config

    Phoenix.PubSub.broadcast(hub, "lights_update", {:lights, :green})
    {:noreply, socket}
  end
end
