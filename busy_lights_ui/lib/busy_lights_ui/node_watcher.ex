defmodule BusyLightsUi.NodeWatcher do
  use GenServer
  require Logger

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    :net_kernel.monitor_nodes(:true,[])
    nodes = Node.list()
    state = %{nodes: nodes}
    {:ok, state}
  end

  def handle_info({:nodeup, node_name}, state) do
    Logger.info("Node UP: #{node_name}")
    nodes = Node.list()
    Phoenix.PubSub.local_broadcast(BusyLightsUi.PubSub, "ui_updates", {:nodes, nodes, :up})
    {:noreply, state}
  end

  def handle_info({:nodedown, node_name}, state) do
    Logger.info("Node DOWN: #{node_name}")
    nodes = Node.list()
    Phoenix.PubSub.local_broadcast(BusyLightsUi.PubSub, "ui_updates", {:nodes, nodes, :down})
    {:noreply, state}
  end
end
