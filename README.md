# Busy Lights
Simple solution for running Elixir, Phoenix and Nerves on a Raspberry Pi Zero with the BLINKT hardware module attached.
Purpose: Show a synchronized light on web, and all attached RPi Zeroes. Usa case for myself is to show if I am accupied in a meeting.

# To get started
To start your Nerves app:

    export MIX_ENV=prod
    cd busy_lights_ui
    mix deps.get
    npm install --prefix assets
    npm install --prefix assets --production
    npm run deploy --prefix assets
    mix phx.digest
    cd ../busy_lights_fw
    export MIX_TARGET=rpi0
    export NERVES_NETWORK_SSID=your_wifi_name
    export NERVES_NETWORK_PSK=your_wifi_password
    mix deps.get
    mix firmware
    mix firmware.burn