-- Hyprland Lua config
-- https://wiki.hypr.land/Configuring/Start/

require("colors")
require("env")
require("monitors")
require("input")
require("appearance")
require("animations")
require("programs")
require("keybinds")
require("startup")
require("windowrules")

-- -- Hyprexpo: workspace overview plugin
-- hl.config({
-- 	plugin = "/var/cache/hyprpm/vito/hyprexpo/hyprexpo.so",
-- })
--
-- hl.config({
-- 	plugin = {
-- 		hyprexpo = {
-- 			columns = 3,
-- 			gap_size = 8,
-- 			bg_col = "rgb(111111)",
-- 			workspace_method = "center current",
-- 			skip_empty = false,
-- 			gesture_distance = 300,
-- 		},
-- 	},
-- })

-- require("hyprland-gui")
