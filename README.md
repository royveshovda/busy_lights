# Busy Lights
Simple solution for running Elixir, Phoenix and Nerves on a Raspberry Pi Zero with the BLINKT hardware module attached.
Purpose: Show a synchronized light on web, and all attached RPi Zeroes. Use case: for myself is to show if I am accupied in a meeting or not.

![](docs/media/demo.gif)

This repo is not in a very public friendly state. If you want to replicate any of this work, feel free to reach out using issues on this repo, and I can explain the missing details.


# Hardware
[Details can be found here](docs/hardware.md)


# Developing
## To get started
To start your Nerves app:

    export MIX_ENV=prod
    cd ui
    mix deps.get
    mix assets.deploy
    cd ../fw
    export MIX_TARGET=rpi0
    mix deps.get
    export NERVES_NETWORK_SSID=your_wifi_name
    export NERVES_NETWORK_PSK=your_wifi_password
    mix firmware
    mix burn


## To update
    mix firmware.gen.script
    ./upload.sh <IP>
