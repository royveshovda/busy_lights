# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
import Config

#import_config("../../busy_lights_ui/config/config.exs")
#import_config("../../busy_lights_ui/config/prod.exs")


config :busy_lights_ui, BusyLightsUiWeb.Endpoint,
url: [host: "nervesl.local", port: 80],
  http: [
    port: 80,
    transport_options: [socket_opts: [:inet6]]
  ],
  secret_key_base: "yeZWsz7Q7FlbEeTuMWKFD+eVOGlmdCqMIH5JLAKxrvyaeRmegB+p2KSIiOz94u2f",
  live_view: [signing_salt: "AAAABjEyERMkxgDh"],
  check_origin: false,
  root: Path.dirname(__DIR__),
  server: true,
  render_errors: [view: UiWeb.ErrorView, accepts: ~w(html json)],
  #pubsub_server: Ui.PubSub,
  pubsub_server: BusyLightsUi.PubSub,
  load_from_system_env: false,
  code_reloader: false,
  cache_static_manifest: "priv/static/cache_manifest.json"

config :phoenix, :json_library, Jason

config :busy_lights_fw, target: Mix.target()

# Customize non-Elixir parts of the firmware. See
# https://hexdocs.pm/nerves/advanced-configuration.html for details.

config :nerves, :firmware, rootfs_overlay: "rootfs_overlay"

config :nerves, :firmware,
  fwup_conf: "config/fwup.conf"

# Set the SOURCE_DATE_EPOCH date for reproducible builds.
# See https://reproducible-builds.org/docs/source-date-epoch/ for more information

config :nerves, source_date_epoch: "1589200147"

config :nerves_ssh,
    authorized_keys: [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJVOpttfJ12x0hAX/jJFqWOfwJAA9c5YBWa6AnvxU+7G", #Mac Studio
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICvC/Rt+pFwCJ82qmR7Q3+RhpSYwpxVpW8FaQsLhq1+X" #Macbook air
    ]

config :libcluster,
  topologies: [
    gossip_clustering: [
      strategy: Elixir.Cluster.Strategy.Gossip,
      config: [
        port: 45892,
        if_addr: "0.0.0.0",
        multicast_addr: "255.255.255.255",
        broadcast_only: true,
        secret: "segment1" # Can be used to segment different versions in same network
      ]
    ]
    # dns_poll_clustering: [
    #   strategy: Elixir.Cluster.Strategy.DNSPoll,
    #   config: [
    #     polling_interval: 5_000,
    #     query: "busy.sb14d",
    #     node_basename: "nerves"
    #   ]
    # ]
  ]

config :libcluster,
  debug: false

# Use Ringlogger as the logger backend and remove :console.
# See https://hexdocs.pm/ring_logger/readme.html for more information on
# configuring ring_logger.

config :logger, backends: [RingLogger]

config :busy_lights_ui, lights_module: BusyLightsFw.Lights

if Mix.target() != :host do
  import_config "target.exs"
end
