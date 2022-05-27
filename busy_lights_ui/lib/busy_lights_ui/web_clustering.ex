defmodule BusyLightsUi.WebClustering do
  # Only for dev purposes
  require Logger

  def prepare_node() do
    start_epmd()
    {:ok, addrs} = :inet.getifaddrs()
    wlan_ids = ['wlp0s20f3', 'enp72s0']
    [{_wlan_id, details}] = addrs |> Enum.filter(fn {nic, _details} -> nic in wlan_ids end)
    [_,{:addr, ip},_,_,_,_,_] = details
    host = Tuple.to_list(ip) |> Enum.join(".")
    node_name = "nerves@" <> host |> String.to_atom

    case Node.alive?() do
      true -> Node.stop()
      _ -> :ok
    end

    {:ok, _pid} = Node.start(node_name)
    #Node.set_cookie(:super_secret_123)

    connect()
  end

  defp start_epmd() do
    case System.cmd("epmd", ["-daemon"]) do
      {:error, {:already_started, _pid}} -> Logger.info("EPMD Already started")
      {"", 0} -> Logger.info("EPMD Started")
      _ -> Logger.warn("Unknown EPMD start status")
    end
    :ok
  end

  defp connect() do
    Node.ping(:"nerves@10.223.80.101")
    Node.ping(:"nerves@10.223.80.102")
    Node.ping(:"nerves@10.223.80.103")
    Node.ping(:"nerves@10.223.80.104")
    Node.ping(:"nerves@10.223.80.105")
  end
end
