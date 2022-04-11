export MIX_ENV=prod
cd busy_lights_ui
mix deps.get
mix assets.deploy
cd ../busy_lights_fw
export MIX_TARGET=rpi0
mix deps.get
#mix firmware
echo "Remeber to run: export NERVES_NETWORK_SSID=your_wifi_name and "
echo "export NERVES_NETWORK_PSK=your_wifi_password"
echo "Finish up with mix firmware && mix burn"