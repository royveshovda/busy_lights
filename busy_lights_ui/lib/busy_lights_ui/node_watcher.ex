defmodule BusyLightsUi.NodeWatcher do
  use GenServer
  require Logger

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    :net_kernel.monitor_nodes(:true,[])
    state = %{}
    Process.send_after(self(), :full_node_list, 60000)
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

  def handle_info(:full_node_list, state) do
    Logger.debug("Full node list")
    nodes = Node.list()
    Phoenix.PubSub.local_broadcast(BusyLightsUi.PubSub, "ui_updates", {:nodes, nodes, :full})
    {:noreply, state}
  end
end
