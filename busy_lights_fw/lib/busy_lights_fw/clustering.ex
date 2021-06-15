defmodule BusyLightsFw.Clustering do
  use GenServer
  require Logger

  def start_link(_opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(_opts) do
    state = %{running: false}
    Logger.info("Clustering server started")
    VintageNet.subscribe(["interface", "wlan0", "addresses"])

    # TODO: Check if has IP already set
    # Start Cluster.SuperVisor if so

    {:ok, state}
  end

  def handle_info({VintageNet, ["interface", "wlan0", "addresses"], _old_value, new_value, _metadata}, %{running: running} = state) do
    #Logger.debug("New WLAN0 UPDATE: old_value: #{inspect(old_value)}, new_value: #{inspect(new_value)}")
    Logger.debug("New WLAN0 IP UPDATE: #{inspect(new_value)}")

    ip_v4_addresses = Enum.filter(new_value, fn x -> x.family == :inet end)

    state =
      case length(ip_v4_addresses) > 0 do # Only use if IPv4 set
        true ->
          prepare_node(running, hd(ip_v4_addresses))
          %{state | running: true}
      _ -> state
    end


    {:noreply, state}
  end

  def handle_info({VintageNet, property_name, old_value, new_value, metadata}, state) do
    Logger.debug("New UPDATE: Property_name: #{inspect(property_name)}, old_value: #{inspect(old_value)}, new_value: #{inspect(new_value)}, meta_data: #{inspect(metadata)}")
    {:noreply, state}
  end

  def handle_info({:ping, node_name}, state) do
    case Node.ping(node_name) do
      :pong -> Logger.info("Connected to: " <> inspect(node_name))
      _ -> Process.send_after(self(), {:ping, node_name}, 10000)
    end
    {:noreply, state}
  end

  defp start_epmd(true) do
    # Do nothing
    :ok
  end

  defp start_epmd(false) do
    case System.cmd("epmd", ["-daemon"]) do
      {:error, {:already_started, _pid}} -> Logger.info("EPMD Already started")
      {"", 0} -> Logger.info("EPMD Started")
      _ -> Logger.warn("Unknown EPMD start status")
    end
    :ok
  end

  defp start_libcluster(true) do
    # Do nothing
    :ok
  end

  defp start_libcluster(false) do
    topologies = Application.get_env(:libcluster, :topologies)
    Cluster.Supervisor.start_link([topologies])
    :ok
  end





  defp prepare_node(running, ip_v4_addresse) do
    Logger.info("Trying to prepare for clustering")
    start_epmd(running)

    ip = ip_v4_addresse.address
    host = Tuple.to_list(ip) |> Enum.join(".")
    node_name = "nerves@" <> host |> String.to_atom

    case Node.alive?() do
      true -> Node.stop()
      _ -> :ok
    end

    {:ok, _pid} = Node.start(node_name)

    # TODO: Start Clustering
    start_libcluster(running)

    Node.set_cookie(:super_secret_123)

    Logger.info("Done preparing for clustering")
  end
end
