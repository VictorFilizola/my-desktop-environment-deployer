local wezterm = require("wezterm")
local act = wezterm.action
local config = wezterm.config_builder()

-- General Window Options
config.window_background_opacity = 0.75
config.window_padding = { left = 3, right = 0, top = 0, bottom = 0 }
config.scrollback_lines = 10000

-- Mux (tmux-like persistence)
config.unix_domains = {
	{ name = "unix" },
}
config.default_gui_startup_args = { "connect", "unix" }

-- Font Configuration
config.font = wezterm.font("JetBrainsMono Nerd Font")
config.font_size = 13

-- Disable new tab button
config.show_new_tab_button_in_tab_bar = false

-- -- Cursor Customization
-- config.default_cursor_style = "BlinkingBar"
-- config.cursor_blink_rate = 500

-- Tab Bar Layout
config.enable_tab_bar = true
config.tab_bar_at_bottom = false
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = false

-- Color Palette (Gruvbox Dark)
config.colors = {
	foreground = "#ebdbb2",
	background = "#1e1e1e",

	cursor_bg = "#ebdbb2",
	cursor_fg = "#1e1e1e",
	cursor_border = "#ebdbb2",

	selection_fg = "#ebdbb2",
	selection_bg = "#264f78",

	split = "#cd3131",

	ansi = {
		"#000000", -- color0
		"#f14c4c", -- color1
		"#23d18b", -- color2
		"#f5f543", -- color3
		"#3b8eea", -- color4
		"#d670d6", -- color5
		"#29b8db", -- color6
		"#e5e5e5", -- color7
	},
	brights = {
		"#666666", -- color8
		"#cd3131", -- color9
		"#0dbc79", -- color10
		"#e5e510", -- color11
		"#2472c8", -- color12
		"#bc3fbc", -- color13
		"#11a8cd", -- color14
		"#e5e5e5", -- color15
	},
	tab_bar = {
		background = "rgba(30, 30, 30, 0.75)",
		active_tab = { bg_color = "rgba(30, 30, 30, 0.75)", fg_color = "#ffffff" },
		inactive_tab = { bg_color = "rgba(30, 30, 30, 0.75)", fg_color = "#858485" },
	},
}

-- Mappings
config.disable_default_key_bindings = false
config.keys = {
	-- Tab switching (Ctrl+Shift+Y/U/I/O/P -> tabs 1-5)
	{ key = "y", mods = "CTRL|SHIFT", action = act.ActivateTab(0) },
	{ key = "u", mods = "CTRL|SHIFT", action = act.ActivateTab(1) },
	{ key = "i", mods = "CTRL|SHIFT", action = act.ActivateTab(2) },
	{ key = "o", mods = "CTRL|SHIFT", action = act.ActivateTab(3) },
	{ key = "p", mods = "CTRL|SHIFT", action = act.ActivateTab(4) },

	-- Pane navigation
	{ key = "LeftArrow", mods = "ALT", action = act.ActivatePaneDirection("Left") },
	{ key = "RightArrow", mods = "ALT", action = act.ActivatePaneDirection("Right") },
	{ key = "UpArrow", mods = "ALT", action = act.ActivatePaneDirection("Up") },
	{ key = "DownArrow", mods = "ALT", action = act.ActivatePaneDirection("Down") },

	-- Pane management
	{ key = "Enter", mods = "CTRL", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "Enter", mods = "CTRL|SHIFT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },

	-- Passthrough rules
	{ key = "c", mods = "CTRL|SHIFT", action = act.DisableDefaultAssignment },
	{ key = "v", mods = "CTRL|SHIFT", action = act.DisableDefaultAssignment },
	{ key = "s", mods = "CTRL", action = act.DisableDefaultAssignment },
	{ key = "q", mods = "CTRL", action = act.DisableDefaultAssignment },

	-- Clipboard
	{ key = "v", mods = "CTRL", action = act.PasteFrom("Clipboard") },
}

config.mouse_bindings = {
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "CTRL",
		action = act.OpenLinkAtMouseCursor,
	},
	-- Scroll wheel: move 5 lines per tick
	{
		event = { Down = { streak = 1, button = { WheelUp = 1 } } },
		mods = "NONE",
		action = act.ScrollByLine(-5),
	},
	{
		event = { Down = { streak = 1, button = { WheelDown = 1 } } },
		mods = "NONE",
		action = act.ScrollByLine(5),
	},
}

local SLANT_LEFT = "\xee\x82\xba"
local SLANT_RIGHT = "\xee\x82\xbc"

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local title = tostring(tab.tab_index + 1)
	local inactive_bg = "rgba(30, 30, 30, 0.75)"

	if tab.is_active then
		local active_bg = "#3a3d41"
		local active_fg = "#eb3131"
		local elements = {}

		-- Left edge: flush or slant
		if tab.tab_index > 0 then
			table.insert(elements, { Background = { Color = inactive_bg } })
			table.insert(elements, { Foreground = { Color = active_bg } })
			table.insert(elements, { Text = SLANT_LEFT })
		else
			table.insert(elements, { Background = { Color = active_bg } })
			table.insert(elements, { Foreground = { Color = active_fg } })
			table.insert(elements, { Text = " " })
		end

		-- Core text
		table.insert(elements, { Background = { Color = active_bg } })
		table.insert(elements, { Foreground = { Color = active_fg } })
		table.insert(elements, { Attribute = { Intensity = "Bold" } })
		table.insert(elements, { Text = " " .. title .. " " })

		-- Right edge: slant
		table.insert(elements, { Background = { Color = inactive_bg } })
		table.insert(elements, { Foreground = { Color = active_bg } })
		table.insert(elements, { Text = SLANT_RIGHT })

		return elements
	else
		local inactive_fg = "#858485"
		return {
			{ Background = { Color = inactive_bg } },
			{ Foreground = { Color = inactive_fg } },
			{ Text = "  " .. title .. "  " },
		}
	end
end)

wezterm.on("gui-attached", function(_domain)
	-- Restore focus to the mux's active tab instead of defaulting to tab 0
	for _, window in ipairs(wezterm.mux.all_windows()) do
		local active_tab = window:active_tab()
		if active_tab then
			active_tab:activate()
		end
	end
end)

return config
