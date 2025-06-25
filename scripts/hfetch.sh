#!/bin/sh
file="$(find /home/based/.local/share/hydrus/db/client_files/ -type f \( -name '*.png' -o -name '*.webp' -o -name '*.jpeg' -o -name '*.jpg' -o -name '*.gif' -o -name '*.icon' -o -name '*.mp4' \) | shuf -n 1)"
if [[ "$file" == *.mp4 ]]; then
  mpv $file 
else
  imv-dir $file
fi
