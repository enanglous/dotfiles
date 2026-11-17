#!/usr/bin/env bash

# Copy rather than symlink so Equibop's theme watcher sees each change
install -m644 ~/.local/state/caelestia/theme/discord-colours.theme.css ~/.config/equibop/themes/discord-colours.theme.css
~/.local/bin/posthooks/fastfetch.sh &
~/.local/bin/posthooks/zapfast.sh &
~/.local/bin/posthooks/spotifast.sh &
# ~/.local/bin/posthooks/flatremix.sh &
# ~/.local/bin/posthooks/steam.sh &
bash -c 'hyprctl eval "hl.dispatch(hl.dsp.send_shortcut({ mods = \"CTRL SHIFT ALT\", key = \"R\", window = \"class:^(Beeper)$\" }))"' &
