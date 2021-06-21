export MIX_ENV=prod
cd busy_lights_ui
mix deps.get
npm install --prefix assets
npm install --prefix assets --production
npm run deploy --prefix assets
mix phx.digest
cd ../busy_lights_fw
export MIX_TARGET=rpi0
mix deps.get
mix compile
mix firmware