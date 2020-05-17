defmodule BusyLightsFw.Clustering do
  use GenServer

  def start_link(_opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def connect() do
    GenServer.call(__MODULE__, :connect)
  end

  def init(_opts) do
    state = %{}
    {:ok, state}
  end

  def handle_call(:connect, _from, state) do
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

    {:reply, :ok, state}
  end
end
