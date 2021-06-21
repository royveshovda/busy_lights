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
    Supervisor.start_link(children, opts)
  end

  # List all child processes to be supervised
  def children(:host) do
    [
    ]
  end

  def children(_target) do
    [
      Blinkt,
      Buttons,
      BusyLightsFw.Clustering,
    ]
  end

  def target() do
    Application.get_env(:busy_lights_fw, :target)
  end
end
