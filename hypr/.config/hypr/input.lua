---------------
---- INPUT ----
---------------

hl.config({
	input = {

		-- brazilian-abnt2
		-- kb_layout = "br",
		-- kb_variant = "abnt2",

		-- us-english-international
		kb_layout = "us",
		kb_variant = "intl",

		kb_model = "",
		kb_options = "",
		kb_rules = "",

		repeat_delay = 200, -- (default 600)
		repeat_rate = 50, -- (default 25)

		follow_mouse = 1,

		sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.

		touchpad = {
			natural_scroll = false,
		},
	},
})

hl.gesture({
	fingers = 3,
	direction = "horizontal",
	action = "workspace",
})

-- Example per-device config
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Devices/ for more
hl.device({
	name = "epic-mouse-v1",
	sensitivity = -0.5,
})
