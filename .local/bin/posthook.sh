#!/usr/bin/env bash

~/.local/bin/posthooks/discord-material.sh &
ln -nsf ~/.local/state/caelestia/theme/discord-material.theme.css ~/.config/equibop/themes/discord-material.theme.css
~/.local/bin/posthooks/fastfetch.sh &
~/.local/bin/posthooks/zapfast.sh &
~/.local/bin/posthooks/spotifast.sh &
# ~/.local/bin/posthooks/flatremix.sh &
# ~/.local/bin/posthooks/steam.sh &
bash -c 'hyprctl eval "hl.dispatch(hl.dsp.send_shortcut({ mods = \"CTRL SHIFT ALT\", key = \"R\", window = \"class:^(Beeper)$\" }))"' &
