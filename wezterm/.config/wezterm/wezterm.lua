local wezterm = require("wezterm")
local act = wezterm.action

local config = {}

-- ── Appearance ──────────────────────────────────────────────
config.color_scheme = "Gruvbox Dark (Gogh)"
config.window_background_opacity = 0.96
config.window_decorations = "RESIZE"
config.enable_tab_bar = true
config.use_fancy_tab_bar = true
config.tab_bar_at_bottom = false
config.tab_max_width = 32
config.window_padding = {
	left = 8,
	right = 8,
	top = 8,
	bottom = 4,
}

-- ── Font ────────────────────────────────────────────────────
config.font = wezterm.font("JetBrainsMono Nerd Font", { weight = "Medium" })
config.font_size = 11.0
config.line_height = 1.2
config.freetype_load_target = "Normal"
config.freetype_render_target = "Normal"

-- ── Cursor ──────────────────────────────────────────────────
config.default_cursor_style = "BlinkingBar"
config.cursor_blink_rate = 1000
config.cursor_blink_ease_in = "Constant"
config.cursor_blink_ease_out = "Constant"

-- ── Colors (matching hyprland red-accent theme) ─────────────
config.colors = {
	tab_bar = {
		background = "#1e1e1e",
		active_tab = {
			bg_color = "#eb3131",
			fg_color = "#1e1e1e",
			intensity = "Bold",
		},
		inactive_tab = {
			bg_color = "#1e1e1e",
			fg_color = "#595959",
		},
		inactive_tab_hover = {
			bg_color = "#2a2a2a",
			fg_color = "#ebdbb2",
			italic = false,
		},
		new_tab = {
			bg_color = "#1e1e1e",
			fg_color = "#595959",
		},
		new_tab_hover = {
			bg_color = "#2a2a2a",
			fg_color = "#ebdbb2",
			italic = false,
		},
	},
}

-- ── Wayland ─────────────────────────────────────────────────
config.enable_wayland = true

-- ── Keybinds ────────────────────────────────────────────────
config.keys = {
	-- Font size
	{ key = "+", mods = "CTRL", action = act.IncreaseFontSize },
	{ key = "-", mods = "CTRL", action = act.DecreaseFontSize },
	{ key = "0", mods = "CTRL", action = act.ResetFontSize },

	-- Tabs
	{ key = "t",          mods = "SUPER",       action = act.SpawnTab("CurrentPaneDomain") },
	{ key = "w",          mods = "SUPER",       action = act.CloseCurrentTab({ confirm = true }) },
	{ key = "Tab",        mods = "CTRL",        action = act.ActivateTabRelative(1) },
	{ key = "Tab",        mods = "CTRL|SHIFT",  action = act.ActivateTabRelative(-1) },

	-- Panes
	{ key = "v",          mods = "SUPER|SHIFT",       action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "h",          mods = "SUPER|SHIFT",       action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "LeftArrow",  mods = "SUPER|SHIFT",       action = act.ActivatePaneDirection("Left") },
	{ key = "RightArrow", mods = "SUPER|SHIFT",       action = act.ActivatePaneDirection("Right") },
	{ key = "UpArrow",    mods = "SUPER|SHIFT",       action = act.ActivatePaneDirection("Up") },
	{ key = "DownArrow",  mods = "SUPER|SHIFT",       action = act.ActivatePaneDirection("Down") },

	-- Clipboard
	{ key = "c",          mods = "CTRL|SHIFT",  action = act.CopyTo("Clipboard") },
	{ key = "v",          mods = "CTRL|SHIFT",  action = act.PasteFrom("Clipboard") },

	-- Misc
	{ key = "L",          mods = "CTRL|SHIFT",  action = act.ClearScrollback("ScrollbackAndViewport") },
}

-- ── Misc ────────────────────────────────────────────────────
config.scrollback_lines = 10000
config.audible_bell = "Disabled"
config.check_for_updates = false
config.show_update_window = false

return config
