#!/bin/bash
# Waybar module: system uptime
read uptime _ </proc/uptime
uptime=${uptime%.*}
d=$((uptime / 86400))
h=$(((uptime % 86400) / 3600))
m=$(((uptime % 3600) / 60))

if [ $d -gt 0 ]; then
  printf '{"text":" %dd%dh","tooltip":"Uptime: %dd%dh%dm"}\n' $d $h $d $h $m
elif [ $h -gt 0 ]; then
  printf '{"text":" %dh%dm","tooltip":"Uptime: %dh%dm"}\n' $h $m $h $m
else
  printf '{"text":" %dm","tooltip":"Uptime: %dm"}\n' $m $m
fi
