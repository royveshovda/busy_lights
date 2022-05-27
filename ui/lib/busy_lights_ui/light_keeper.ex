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

  def publish(color) do
    Logger.debug("1 (#{color})")
    GenServer.cast(__MODULE__, {:publish_lights, color})
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

    from = Node.self()
    sent_at = :os.system_time(:millisecond)
    {time, :ok} = :timer.tc(&Phoenix.PubSub.broadcast/3, [BusyLightsUi.PubSub, "lights_update", {:lights, lights, from, sent_at}])
    Logger.debug(time)
    :telemetry.execute([:busy_lights_ui, :pubsub, :runtime],%{broadcast: time},%{lights: lights})
    #Phoenix.PubSub.broadcast(BusyLightsUi.PubSub, "lights_update", {:lights, lights})
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
          lights_module.set_color(lights)
          %{state | lights: lights, state_request_id: nil}
        _ -> state # not my request
      end
    {:noreply, state}
  end

  def handle_info({:lights, color, from, sent_at}, %{lights_module: lights_module} = state) do
    Logger.info("2 Got #{color}")

    received_at = :os.system_time(:millisecond)
    diff = received_at - sent_at
    Logger.debug("From: #{ from }")
    Logger.debug("PubSub time: #{diff}")
    :telemetry.execute([:busy_lights_ui, :pubsub, :runtime],%{pubsub: diff},%{lights: color})

    publish_ui_lights_update(color)

    lights_module.set_color(color)
    {:noreply, %{state | lights: color}}
  end

  defp publish_ui_lights_update(color) do
    # Only broadcast on local node
    Phoenix.PubSub.local_broadcast(BusyLightsUi.PubSub, "ui_updates", {:lights, color})
  end
end
