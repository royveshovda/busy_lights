defmodule BusyLightsUi.LightKeeper do
  use GenServer
  require Logger

  @delay 5000
  @attempts_limit 5

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    Phoenix.PubSub.subscribe(BusyLightsUi.PubSub, "lights_update")
    lights_module = Application.get_env(:busy_lights_ui, :lights_module)
    state = %{lights: :blank, state_request_id: 0, lights_module: lights_module}
    {:ok, state}
  end

  def get_light() do
    GenServer.call(__MODULE__, :get_light)
  end

  def connected() do
    GenServer.cast(__MODULE__, :connected)
  end

  def publish_red() do
    Logger.debug("1 (RED)")
    GenServer.cast(__MODULE__, {:publish_lights, :red})
  end

  def publish_yellow() do
    Logger.debug("1 (YELLOW)")
    GenServer.cast(__MODULE__, {:publish_lights, :yellow})
  end

  def publish_green() do
    Logger.debug("1 (GREEN)")
    GenServer.cast(__MODULE__, {:publish_lights, :green})
  end

  def publish_blank() do
    Logger.debug("1 (<BLANK>)")
    GenServer.cast(__MODULE__, {:publish_lights, :blank})
  end

  def handle_call(:get_light, _from, %{lights: lights} = state) do
    {:reply, lights, state}
  end

  def handle_cast(:connected,  %{state_request_id: state_request_id} = state) when state_request_id == 0 do
    Logger.info("LIGHTKEEPER Connected. Starting state request")
    correlation_id = :rand.uniform(1000000) +1
    Process.send_after(self(), {:request_state, 1}, @delay)
    {:noreply, %{state | state_request_id: correlation_id}}
  end

  def handle_cast(:connected,  %{state_request_id: state_request_id} = state) when state_request_id > 0 do
    Logger.info("State already requested")
    {:noreply, state}
  end

  def handle_cast({:publish_lights, lights}, state) do
    Logger.debug("Broadcast starting...")
    Phoenix.PubSub.broadcast(BusyLightsUi.PubSub, "lights_update", {:lights, lights})
    Logger.debug("Broadcast done")
    {:noreply, state}
  end

  def handle_info({:request_state, attempt}, %{state_request_id: state_request_id} = state) when  attempt <= @attempts_limit do
    Logger.info("Request state from other node(s). Attempt: #{inspect(attempt)}")
    case length(Node.list()) > 0 do
      true ->
        Phoenix.PubSub.broadcast(BusyLightsUi.PubSub, "lights_update", {:lights_status_request, state_request_id})
      _ ->
        Process.send_after(self(), {:request_state, attempt+1}, @delay)
    end
    {:noreply, state}
  end

  def handle_info({:request_state, attempt}, state) when @attempts_limit < attempt do
    Logger.info("No node(s) available -- giving up")
    {:noreply, %{state | state_request_id: 0}}
  end

  def handle_info({:lights_status_request, correlation_id}, %{lights: lights, state_request_id: state_request_id} = state) do
    case state_request_id == correlation_id do
      true -> :ok # Own request
      _ ->
        Logger.info("Got status request")
        Phoenix.PubSub.broadcast(BusyLightsUi.PubSub, "lights_update", {:lights_status_response, lights, correlation_id})
    end
    {:noreply, state}
  end

  def handle_info({:lights_status_response, lights, correlation_id}, %{state_request_id: state_request_id, lights_module: lights_module} = state) do
    state =
      case correlation_id == state_request_id do
        true ->
          Logger.info("Got status response: #{inspect(lights)}")
          set_lights(lights, lights_module)
          %{state | lights: lights, state_request_id: nil}
        _ -> state # not my request
      end
    {:noreply, state}
  end

  def handle_info({:lights, :red}, %{lights_module: lights_module} = state) do
    Logger.info("2 Got Red")
    publish_ui_lights_update(:red)
    set_lights(:red, lights_module)
    {:noreply, %{state | lights: :red}}
  end

  def handle_info({:lights, :yellow}, %{lights_module: lights_module} = state) do
    Logger.info("2 Got Yellow")
    publish_ui_lights_update(:yellow)
    set_lights(:yellow, lights_module)
    {:noreply, %{state | lights: :yellow}}
  end

  def handle_info({:lights, :green}, %{lights_module: lights_module} = state) do
    Logger.info("2 Got Green")
    publish_ui_lights_update(:green)
    set_lights(:green, lights_module)
    {:noreply, %{state | lights: :green}}
  end

  def handle_info({:lights, :blank}, %{lights_module: lights_module} = state) do
    Logger.info("2 Got Blank")
    publish_ui_lights_update(:blank)
    set_lights(:blank, lights_module)
    {:noreply, %{state | lights: :blank}}
  end

  defp publish_ui_lights_update(color) do
    # Only broadcast on local node
    Phoenix.PubSub.local_broadcast(BusyLightsUi.PubSub, "ui_updates", {:lights, color})
  end

  defp set_lights(:red, lights_module), do: lights_module.red()
  defp set_lights(:yellow, lights_module), do: lights_module.yellow()
  defp set_lights(:green, lights_module), do: lights_module.green()
  defp set_lights(:blank, lights_module), do: lights_module.blank()
end
