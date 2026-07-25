-- Add Waybar - custom taskbar for hyprland
hl.exec_cmd("pkill -x waybar || true; waybar")
hl.exec_cmd("waybar")

-- Add network manager applet
hl.exec_cmd("pkill -x nm-applet || true; nm-applet")

-- Add bluetooth manager applet
hl.exec_cmd("pkill -x blueman-applet || true; blueman-applet")

-- Add swaync - custom notifications daemon
hl.exec_cmd("pkill -x swaync || true; swaync")

-- Add wallpaper (boot + reload)
hl.on("hyprland.start", function()
	-- Add swayosd-server - custom daemon to show graphically volume and brightness changes
	hl.exec_cmd("pkill -x swayosd-server || true; swayosd-server")
		hl.exec_cmd("hypridle")
		hl.exec_cmd("wezterm-mux-server --daemonize")
		hl.exec_cmd("waybar")
	hl.exec_cmd(
		'killall swaybg 2>/dev/null; swaybg -o "*" -i $HOME/Pictures/wallpapers/black-waves-wallpaper.jpg -m fill'
	)
end)
