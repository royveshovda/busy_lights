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

    res = Supervisor.start_link(children, opts)

    start_wifi_wizard_when_needed()

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
    topologies = Application.get_env(:libcluster, :topologies)
    Logger.info(inspect(topologies))
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

  defp start_wifi_wizard_when_needed() do
    if should_start_wizard?() do
      Logger.info("VintageNetWizard starting")
      VintageNetWizard.run_wizard(on_exit: {__MODULE__, :handle_wizard_exit, []})
      Lights.blue()
    else
      Logger.debug("wlan0 configured, skipping VintageNetWizard")
      Application.ensure_all_started(:busy_lights_ui)
      BusyLightsFw.Clustering.connect()
      Lights.white()
    end
  end

  @doc false
  def handle_wizard_exit() do
    Logger.info("VintageNetWizard stopped")
    Application.ensure_all_started(:busy_lights_ui)
    Blinkt.clear()
    Lights.white()
    # TODO: Query other nodes for status
    BusyLightsFw.Clustering.connect()
  end

  defp should_start_wizard? do
    "wlan0" not in VintageNet.configured_interfaces()
  end
end
