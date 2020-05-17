defmodule BusyLightsFw.Clustering do
  use GenServer
  require Logger

  def start_link(_opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def connect() do
    GenServer.call(__MODULE__, :connect)
  end

  def init(_opts) do
    state = %{}
    Logger.info("Clustering server started")
    {:ok, state}
  end

  def handle_call(:connect, _from, state) do
    Process.send_after(self(), :connect_delayed, 60000)
    {:reply, :ok, state}
  end

  def handle_info(:connect_delayed, state) do
    prepare_node()
    start_pinging()
    {:noreply, state}
  end

  def handle_info({:ping, node_name}, state) do
    case Node.ping(node_name) do
      :pong -> Logger.info("Connected to: " <> inspect(node_name))
      _ -> Process.send_after(self(), {:ping, node_name}, 10000)
    end
    {:noreply, state}
  end

  defp start_pinging() do
    [:"nerves@192.168.50.123", :"nerves@192.168.50.218", :"nerves@192.168.50.224", :"nerves@192.168.50.114", :"nerves@192.168.50.211"]
    |> Enum.map(fn node_name -> Process.send_after(self(), {:ping, node_name}, 10000) end)
  end

  defp prepare_node() do
    Logger.info("Trying to prepare for clustering")
    {"", 0} = System.cmd("epmd", ["-daemon"])

    {:ok, addrs} = :inet.getifaddrs()
    [{'wlan0', details}] = addrs |> Enum.filter fn {nic, _details} -> nic == 'wlan0' end
    [_,{:addr, ip},_,_,_,_,_] = details
    host = Tuple.to_list(ip) |> Enum.join(".")


    #{:ok, hn} = :inet.gethostname()
    #node_name = "nerves@" <> to_string(hn) <> ".local" |> String.to_atom
    node_name = "nerves@" <> host |> String.to_atom

    {:ok, _pid} = Node.start(node_name)

    Node.set_cookie(:super_secret_123)

    Logger.info("Done preparing for clustering")
  end
end
