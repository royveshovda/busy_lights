import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :busy_lights_ui, BusyLightsUiWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "J9Zh/ctf3lv7Ep3WDyfVfd8WaUHJsDAZ329yMqOBjMqRS+71rVjfpTbgyVBFalvp",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true
