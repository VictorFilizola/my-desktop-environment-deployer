local programs = require("programs")
local terminal = programs.terminal
local fileManager = programs.fileManager
local menu = programs.menu
-- local browser = programs.browser

-- Screenshots: Print = annotate, SUPER+Shift+S = quick copy
hl.bind("Print", hl.dsp.exec_cmd("hyprshot -m region | swappy -f -"))
hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd("hyprshot -m region --clipboard-only"))

local mainMod = "SUPER" -- Sets "Windows" key as main modifier

-- Example binds, see https://wiki.hypr.land/Configuring/Basics/Binds/ for more
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
-- local closeWindowBind = hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + Escape", hl.dsp.exec_cmd("hyprlock"))
-- closeWindowBind:set_enabled(false)
-- hl.bind(
-- 	mainMod .. " + M",
-- 	hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'")
-- )

-- Toggles current window in and out of tiling mode
hl.bind(mainMod .. " + G", function()
	local win = hl.get_active_window()
	if not win then
		return
	end

	local was_floating = win.floating
	hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
	if not was_floating then
		local mon = hl.get_active_monitor()
		if mon then
			hl.dispatch(hl.dsp.window.resize({
				x = math.floor(mon.width * 0.5),
				y = math.floor(mon.height * 0.5),
				relative = false,
			}))
		end
		hl.dispatch(hl.dsp.window.center())
	end
end)

hl.bind(mainMod .. " + H", hl.dsp.exec_cmd("hyprmod"))
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.exec_cmd("XDG_CURRENT_DESKTOP=GNOME gnome-control-center"))

hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("pavucontrol"))
hl.bind(mainMod .. " + Space", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit")) -- dwindle only

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + SHIFT + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + down", hl.dsp.focus({ direction = "down" }))

-- Switch workspaces with mainMod + Y/U/I/O/P (1-5)
-- Move active window to a workspace with mainMod + SHIFT + Y/U/I/O/P
local workspaceKeys = { "Y", "U", "I", "O", "P" }
for i, key in ipairs(workspaceKeys) do
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- -- Switch workspaces with mainMod + 1~0 (1-10)
-- -- Move active window to a workspace with mainMod + SHIFT + 1~0
-- local workspaceKeyNumbers = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "0" }
-- for i, key in ipairs(workspaceKeyNumbers) do
-- 	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
-- 	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
-- end

-- Workspace 6 (scratch / overflow)
hl.bind(mainMod .. " + Backspace", hl.dsp.focus({ workspace = 6 }))
hl.bind(mainMod .. " + SHIFT + Backspace", hl.dsp.window.move({ workspace = 6 }))

-- Example special workspace (scratchpad)
--hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
--hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
-- hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "+1" }))
-- hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "-1" }))
hl.bind(mainMod .. " + left", hl.dsp.focus({ workspace = "-1" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ workspace = "+1" }))

-- -- Hyprexpo: workspace overview (like GNOME Activities / macOS Mission Control)
-- hl.bind(mainMod .. " + Tab", function()
-- 	hl.dispatch("hyprexpo:expo", "toggle")
-- end)

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Multimedia keys for volume and LCD brightnes
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("swayosd-client --output-volume raise"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("swayosd-client --output-volume lower"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd("swayosd-client --output-volume mute-toggle"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86MonBrightnessUp",
	hl.dsp.exec_cmd("swayosd-client --brightness raise"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86MonBrightnessDown",
	hl.dsp.exec_cmd("swayosd-client --brightness lower"),
	{ locked = true, repeating = true }
)

-- Requires playerctl
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
