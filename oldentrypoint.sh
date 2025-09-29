#!/bin/bash
# Run as root

export DISPLAY=${DISPLAY:-":0.0"}
export PORT=${PORT:-"8080"}

export WIDTH=${WIDTH:-"1920"}
export HEIGHT=${HEIGHT:-"1080"}
export DEPTH=${DEPTH:-"24"}
export BITPERPIXEL=${BITPERPIXEL:="32"}

export SCREEN="${WIDTH}x${HEIGHT}x${DEPTH}+${BITPERPIXEL}"

echo "Port: $PORT"
echo "DISPLAY: $DISPLAY"
echo "Screen: $SCREEN"
echo "Starting xpra with following arguments: $@"

xpra start \
  --bind-tcp=0.0.0.0:$PORT \
  --html=on \
  --printing=no \
  --dbus=no \
  --dbus-control=no \
  --dbus-launch=no \
  --mdns=no \
  --daemon=no \
  $@ \
  --xvfb="Xvfb +extension GLX +extension Composite +extension RANDR +extension RENDER -extension DOUBLE-BUFFER -screen 0 $SCREEN -ac -listen tcp -noreset -dpi 96x96" \
  $DISPLAY

