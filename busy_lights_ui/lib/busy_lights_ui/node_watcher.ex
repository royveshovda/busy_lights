defmodule BusyLightsUi.NodeWatcher do
  use GenServer
  require Logger

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def get_nodes() do
    nodes =
      Node.list() ++ [Node.self()]
      |> Enum.sort()
    {nodes, Node.self()}
  end

  def init(_) do
    :net_kernel.monitor_nodes(:true,[])
    state = %{}
    {:ok, state}
  end

  def handle_info({:nodeup, node_name}, state) do
    Logger.info("Node UP: #{node_name}")
    nodes = get_nodes()
    Phoenix.PubSub.local_broadcast(BusyLightsUi.PubSub, "ui_updates", {:nodes, nodes, :up})
    {:noreply, state}
  end

  def handle_info({:nodedown, node_name}, state) do
    Logger.info("Node DOWN: #{node_name}")
    nodes = get_nodes()
    Phoenix.PubSub.local_broadcast(BusyLightsUi.PubSub, "ui_updates", {:nodes, nodes, :down})
    {:noreply, state}
  end
end
