defmodule BusyLightsUi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      BusyLightsUiWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: BusyLightsUi.PubSub},
      # Start the Endpoint (http/https)
      BusyLightsUiWeb.Endpoint,
      # Start a worker by calling: BusyLightsUi.Worker.start_link(arg)
      # {BusyLightsUi.Worker, arg}
      BusyLightsUi.LightKeeper,
      BusyLightsUi.NodeWatcher
    ] ++ get_extra_apps()

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: BusyLightsUi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp get_extra_apps() do
    Application.get_env(:busy_lights_ui,:extra_apps_to_start, [])
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    BusyLightsUiWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
