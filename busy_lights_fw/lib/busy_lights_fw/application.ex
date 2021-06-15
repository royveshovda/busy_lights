defmodule BusyLightsFw.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger

  def start(_type, _args) do
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: BusyLightsFw.Supervisor]
    children =
      [
        # Children for all targets
        # Starts a worker by calling: BusyLightsFw.Worker.start_link(arg)
        # {BusyLightsFw.Worker, arg},
      ] ++ children(target())

    #Logger.info("PREPARE")
    #prepare_node_for_distribution()
    #Logger.info("DONE")

    res = Supervisor.start_link(children, opts)



    res
  end

  # List all child processes to be supervised
  def children(:host) do
    [
      # Children that only run on the host
      # Starts a worker by calling: BusyLightsFw.Worker.start_link(arg)
      # {BusyLightsFw.Worker, arg},
    ]
  end

  def children(_target) do
    #topologies = Application.get_env(:libcluster, :topologies)
    #Logger.info(inspect(topologies))
    [
      # Children for all targets except host
      # Starts a worker by calling: BusyLightsFw.Worker.start_link(arg)
      # {BusyLightsFw.Worker, arg},
      {Phoenix.PubSub, name: :hub},
      Blinkt,
      Buttons,
      BusyLightsFw.Clustering,
      #{Cluster.Supervisor, [topologies, [name: BusyLightsFw.ClusterSupervisor]]},
      BusyLightsFw.UpdateSubscriber,
    ]
  end

  def target() do
    Application.get_env(:busy_lights_fw, :target)
  end

  # defp start_wifi_wizard_when_needed() do
  #   if should_start_wizard?() do
  #     Logger.info("VintageNetWizard starting")
  #     VintageNetWizard.run_wizard(on_exit: {__MODULE__, :handle_wizard_exit, []})
  #     Lights.blue()
  #   else
  #     Logger.debug("wlan0 configured, skipping VintageNetWizard")
  #     Application.ensure_all_started(:busy_lights_ui)
  #     BusyLightsFw.Clustering.connect()
  #     Lights.white()
  #   end
  # end

  # @doc false
  # def handle_wizard_exit() do
  #   Logger.info("VintageNetWizard stopped")
  #   Application.ensure_all_started(:busy_lights_ui)
  #   Blinkt.clear()
  #   Lights.white()
  #   # TODO: Query other nodes for status
  #   BusyLightsFw.Clustering.connect()
  # end

  # defp should_start_wizard? do
  #   "wlan0" not in VintageNet.configured_interfaces()
  # end

  # defp prepare_node_for_distribution() do
  #   Logger.info("Trying to prepare for clustering")
  #   {"", 0} = System.cmd("epmd", ["-daemon"])

  #   {:ok, addrs} = :inet.getifaddrs()
  #   [{'wlan0', details}] = addrs |> Enum.filter(fn {nic, _details} -> nic == 'wlan0' end)
  #   [_,{:addr, ip},_,_,_,_,_] = details
  #   host = Tuple.to_list(ip) |> Enum.join(".")
  #   node_name = "nerves@" <> host |> String.to_atom

  #   #{:ok, hn} = :inet.gethostname()
  #   #node_name = "nerves@" <> to_string(hn) <> ".local" |> String.to_atom


  #   {:ok, _pid} = Node.start(node_name)

  #   Node.set_cookie(:super_secret_123)

  #   Logger.info("Done preparing for clustering")
  # end
end
