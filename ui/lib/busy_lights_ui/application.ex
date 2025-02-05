defmodule BusyLightsUi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children =
      [
        BusyLightsUiWeb.Telemetry,
        {DNSCluster, query: Application.get_env(:busy_lights_ui, :dns_cluster_query) || :ignore},
        {Phoenix.PubSub, name: BusyLightsUi.PubSub},
        # Start a worker by calling: BusyLightsUi.Worker.start_link(arg)
        # {BusyLightsUi.Worker, arg},
        # Start to serve requests, typically the last entry
        BusyLightsUiWeb.Endpoint,
        BusyLightsUi.LightKeeper,
        BusyLightsUi.NodeWatcher
      ] ++ get_extra_apps()

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: BusyLightsUi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    BusyLightsUiWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp get_extra_apps() do
    Application.get_env(:busy_lights_ui, :extra_apps_to_start, [])
  end
end
