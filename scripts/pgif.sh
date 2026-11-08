#!/usr/bin/env bash
set -euo pipefail

GIF_DIR="${1:-$HOME/Pictures}"

if [[ ! -d "$GIF_DIR" ]]; then
  echo "Error: Directory '$GIF_DIR' does not exist." >&2
  exit 1
fi

# Find all .gif files in the folder into an array
mapfile -t GIF_FILES < <(find "$GIF_DIR" -maxdepth 1 -type f -iname "*.gif")

if [[ ${#GIF_FILES[@]} -eq 0 ]]; then
  echo "Error: No GIF files found in '$GIF_DIR'." >&2
  exit 1
fi

# Pick a random index from the array
RANDOM_INDEX=$((RANDOM % ${#GIF_FILES[@]}))
SELECTED_GIF="${GIF_FILES[$RANDOM_INDEX]}"

echo "Playing random GIF: $SELECTED_GIF"

# Extract dimensions (Width x Height)
DIMENSIONS=$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=s=x:p=0 "$SELECTED_GIF")

if [[ -z "$DIMENSIONS" ]]; then
  echo "Error: Failed to extract dimensions from '$SELECTED_GIF'." >&2
  exit 1
fi

IFS='x' read -r WIDTH HEIGHT <<<"$DIMENSIONS"

# Cap maximum height at 400px while maintaining aspect ratio
MAX_HEIGHT=400

if [[ -n "$HEIGHT" && "$HEIGHT" -gt "$MAX_HEIGHT" ]]; then
  WIDTH=$((WIDTH * MAX_HEIGHT / HEIGHT))
  HEIGHT=$MAX_HEIGHT
fi

GEOMETRY="${WIDTH}x${HEIGHT}"

# Launch mpv
mpv --script-opts=uosc-disable=yes \
  --title="desktop-gif" \
  --loop=inf \
  --background=none \
  --gpu-context=wayland \
  --geometry="$GEOMETRY" \
  "$SELECTED_GIF"
