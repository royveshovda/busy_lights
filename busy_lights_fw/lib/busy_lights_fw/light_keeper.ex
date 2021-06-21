defmodule BusyLightsFw.LightKeeper do
  use GenServer

  require Logger

  @delay 5000
  @attempts_limit 5

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    hub = Application.get_env(:busy_lights_fw, :lights_pub_sub_hub)
    Phoenix.PubSub.subscribe(hub, "lights_update")
    state = %{lights: :blank, state_request_id: 0}
    {:ok, state}
  end

  def connected() do
    GenServer.cast(__MODULE__, :connected)
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

  def handle_info({:request_state, attempt}, %{state_request_id: state_request_id} = state) when  attempt <= @attempts_limit do
    Logger.info("Request state from other node(s). Attempt: #{inspect(attempt)}")
    case length(Node.list()) > 0 do
      true ->
        hub = Application.get_env(:busy_lights_fw, :lights_pub_sub_hub)
        Phoenix.PubSub.broadcast(hub, "lights_update", {:lights_status_request, state_request_id})
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
        hub = Application.get_env(:busy_lights_fw, :lights_pub_sub_hub)
        Phoenix.PubSub.broadcast(hub, "lights_update", {:lights_status_response, lights, correlation_id})
    end
    {:noreply, state}
  end

  def handle_info({:lights_status_response, lights, correlation_id}, %{state_request_id: state_request_id} = state) do
    state =
      case correlation_id == state_request_id do
        true ->
          Logger.info("Got status response: #{inspect(lights)}")
          set_lights(lights)
          %{state | lights: lights, state_request_id: nil}
        _ -> state # not my request
      end
    {:noreply, state}
  end

  def handle_info({:lights, :red}, state) do
    Logger.info("Got Red")
    set_lights(:red)
    {:noreply, %{state | lights: :red}}
  end

  def handle_info({:lights, :yellow}, state) do
    Logger.info("Got Yellow")
    set_lights(:yellow)
    {:noreply, %{state | lights: :yellow}}
  end

  def handle_info({:lights, :green}, state) do
    Logger.info("Got Green")
    set_lights(:green)
    {:noreply, %{state | lights: :green}}
  end

  def handle_info({:lights, :blank}, state) do
    Logger.info("Got Blank")
    set_lights(:blank)
    {:noreply, %{state | lights: :blank}}
  end

  defp set_lights(:red), do: Lights.red()
  defp set_lights(:yellow), do: Lights.yellow()
  defp set_lights(:green), do: Lights.green()
  defp set_lights(:blank), do: Lights.blank()

end
