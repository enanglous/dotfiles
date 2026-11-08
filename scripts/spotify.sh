#!/bin/bash
if hyprctl clients | grep -q "class: Spotify"; then
  hyprctl eval 'hl.dispatch(hl.dsp.focus({ window = "spotify" }))'
else
  spicetify watch -s &
fi
