defmodule BusyLightsUi.LightKeeper do
  use GenServer
  require Logger

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    hub = Application.get_env(:busy_lights_ui, :lights_pub_sub_hub)
    Phoenix.PubSub.subscribe(hub, "lights_update")
    state = %{lights: :blank, state_request_id: 0}
    {:ok, state}
  end

  def get_light() do
    GenServer.call(__MODULE__, :get_light)
  end

  def handle_call(:get_light, _from, %{lights: lights} = state) do
    {:reply, lights, state}
  end

  def handle_info({:lights, :red}, state) do
    Logger.info("Got Red")
    {:noreply, %{state | lights: :red}}
  end

  def handle_info({:lights, :yellow}, state) do
    Logger.info("Got Yellow")
    {:noreply, %{state | lights: :yellow}}
  end

  def handle_info({:lights, :green}, state) do
    Logger.info("Got Green")
    {:noreply, %{state | lights: :green}}
  end

  def handle_info({:lights, :blank}, state) do
    Logger.info("Got Blank")
    {:noreply, %{state | lights: :blank}}
  end
end
