#!/bin/bash
class=$(hyprctl activewindow -j 2>/dev/null | jq -r '.class // empty')
class="${class//org.wezfurlong.wezterm/wezterm}"
if [ -n "$class" ]; then
    printf '{"text": " %s", "class": "focused"}\n' "${class,,}"
else
    printf '{"text": "", "class": "empty"}\n'
fi
