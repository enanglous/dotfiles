local vars = require("hypr-vars")

hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })

hl.device({
	name = "semico-usb-keyboard",
	kb_layout = "uk",
})

hl.on("hyprland.start", function()
	hl.exec_cmd("fusuma -d")
	hl.exec_cmd("thunar", { workspace = "special:dolphin silent" })
	hl.exec_cmd([[
    bash -c '
        FLAG="/tmp/hypr_boot"
        
        # Exit if the flag already exists (logout/login check)
        if [ -f "$FLAG" ]; then
            exit 0
        fi
        touch "$FLAG"

        # Wait until Quickshell is running
        while ! pgrep -x "qs" >/dev/null && ! pgrep -x "quickshell" >/dev/null; do
            sleep 0.5
        done

        # Allow layer surfaces to settle, then lock
        sleep 1
        caelestia shell lock lock
    ' &
  ]])
end)

hl.config({
	input = {
		kb_layout = "us",
		sensitivity = 0.7,
		kb_options = "caps:escape_shifted_capslock",
		touchpad = {
			natural_scroll = "1",
		},
		repeat_delay = 250,
		repeat_rate = 60,
	},
	general = {
		snap = {
			enabled = true,
		},
		gaps_in = 2,
	},
	master = {
		new_on_top = true,
	},
})

-- WINDOW RULES --
hl.window_rule({
	match = {
		class = "^(Bitwarden|fdm|blueman-manager|Friends List|localsend|com/korcankaraokcu/PINCE.github.python3|xdg-desktop-portal-gtk)$",
	},
	persistent_size = true,
	tag = "+float",
})
hl.window_rule({
	match = {
		class = "^(spotifast)$",
	},
	tag = "+music_player",
})
hl.window_rule({
	match = {
		tag = "music_player",
	},
	workspace = "10",
})
hl.window_rule({
	match = {
		tag = "communication_app",
	},
	workspace = "7",
})
hl.window_rule({
	match = {
		title = "^(AnimaTux)$",
	},
	size = "465 465",
	float = true,
	no_blur = true,
	border_size = 0,
	no_shadow = true,
	pin = true,
	keep_aspect_ratio = true,
	no_follow_mouse = 1,
	move = { "monitor_w-window_w-20", "monitor_h-window_h-190" },
})

-- KEYBINDS --
hl.unbind(vars.mainMod .. "+ Super_L")
hl.unbind(vars.mainMod .. "+ W")
hl.unbind(vars.mainMod .. "+ Period")
hl.unbind(vars.mainMod .. "+ D")
hl.unbind(vars.mainMod .. "+ P")
hl.unbind(vars.mainMod .. "+ V")
hl.unbind(vars.mainMod .. "+ F")
hl.unbind(vars.mainMod .. "+ M")
hl.unbind(vars.mainMod .. "+ Shift + M")
hl.unbind(vars.mainMod .. "+ Shift + M")
hl.unbind("F11")
for i = 0, 9 do
	-- Unbind the key combination
	hl.unbind(vars.mainMod .. " + ALT + " .. i)
end
for i = 0, 9 do
	-- Unbind the key combination
	hl.unbind(vars.mainMod .. " + SHIFT + " .. i)
end

hl.bind(vars.mainMod .. "+ A", hl.dsp.global("caelestia:launcher"))
hl.bind(vars.mainMod .. "+ V", hl.dsp.exec_cmd("stowaway --toggle"))
hl.bind(vars.mainMod .. "+ Period", hl.dsp.exec_cmd("stowaway --emoji"))
hl.bind(vars.mainMod .. "+ SHIFT + W", hl.dsp.global("caelestia:wallpaper"))
hl.bind(vars.mainMod .. " + W", function()
	hl.dispatch(hl.dsp.window.float("toggle"))
end)
hl.bind(vars.mainMod .. " + P", function()
	hl.dispatch(hl.dsp.window.float("enable"))
	hl.dispatch(hl.dsp.window.pin())
end)
hl.bind("ALT + RETURN", function()
	hl.dispatch(hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
end)
hl.bind(vars.mainMod .. "+ F", function()
	hl.dispatch(hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))
end)
hl.bind(vars.mainMod .. "+ M", function()
	hl.dispatch(hl.dsp.window.cycle_next())
end)
hl.bind(vars.mainMod .. " + SHIFT + N", function()
	local focused = hl.dispatch(hl.dsp.focus({ window = "class:" .. vars.musicPlayer }))
	if not focused then
		hl.dispatch(hl.dsp.exec_cmd(vars.musicPlayer))
	end
end, { description = "Switch to Spotify or open it" })
hl.bind(vars.mainMod .. "+ O", function()
	hl.dispatch(hl.dsp.window.set_prop({ prop = "opaque", value = "toggle" }))
end)

-- PROGRAMS --
hl.bind(vars.mainMod .. "+ D", hl.dsp.exec_cmd(vars.discord))
hl.bind(vars.mainMod .. "+ B", hl.dsp.exec_cmd(vars.browser))
hl.bind(vars.mainMod .. "+ SHIFT + H", hl.dsp.exec_cmd("unset WAYLAND_DISPLAY; hydrus-client"))
hl.bind("CTRL + ALT + H", hl.dsp.exec_cmd("~/.cargo/bin/animatux ~/Pictures/Malfoid\\ Animation.gif"))
hl.bind(vars.mainMod .. "+ SHIFT + N", hl.dsp.exec_cmd(vars.musicPlayer))

hl.bind("F10", hl.dsp.exec_cmd("playerctl --player=playerctld play-pause"))
hl.bind("F12", hl.dsp.exec_cmd("playerctl --player=playerctld volume 0.05-"))
hl.bind("F11", hl.dsp.exec_cmd("playerctl --player=playerctld volume 0.05+"))

for i = 1, 10 do
	local key = i % 10
	hl.bind(vars.mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ window = "activewindow", workspace = i }))
end

hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "down", action = "unset" })

dofile("/home/base/.config/caelestia/animations/fast.lua")
