#!/bin/bash
# Listen to Hyprland IPC for activewindow changes, signal waybar instantly.
# Replaces polling in custom/window module (was interval=1, now signal=8).
SOCKET="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"
if [ ! -S "$SOCKET" ]; then
  echo "Hyprland socket not found: $SOCKET" >&2
  exit 1
fi
socat -U - UNIX-CONNECT:"$SOCKET" 2>/dev/null | while read -r line; do
  case "$line" in
    activewindowv2*) pkill -RTMIN+8 waybar ;;
    activewindow*)   pkill -RTMIN+8 waybar ;;
  esac
done
