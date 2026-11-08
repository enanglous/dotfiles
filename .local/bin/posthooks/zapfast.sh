#!/usr/bin/env bash
# Generate a ZapFast theme from caelestia's wallpaper-derived Material You scheme,
# then hot-reload it in the running ZapFast.

set -euo pipefail

SCHEME="$HOME/.local/state/caelestia/scheme.json"
THEME_DIR="$HOME/.config/zapfast/themes"
THEME_FILE="$THEME_DIR/Wallpaper.json"

if [[ ! -f "$SCHEME" ]]; then
	echo "Scheme not found: $SCHEME"
	exit 1
fi

mkdir -p "$THEME_DIR"
tmp="$(mktemp "$THEME_DIR/.Wallpaper.XXXXXX")"
chmod 644 "$tmp"
trap 'rm -f "$tmp"' EXIT

python3 -I - "$SCHEME" >"$tmp" <<'EOF'
import colorsys, json, sys

scheme = json.load(open(sys.argv[1]))
c = scheme["colours"]
dark = scheme.get("mode", "dark") != "light"

def rgb(h):
    return tuple(int(h[i:i+2], 16) / 255 for i in (0, 2, 4))

def hexc(t):
    return "#" + "".join(f"{round(max(0, min(1, v)) * 255):02x}" for v in t)

def mix(a, b, t):
    a, b = rgb(a), rgb(b)
    return hexc(tuple(x + (y - x) * t for x, y in zip(a, b)))

# Warning amber, nudged toward the wallpaper's primary hue so it blends in
ph, pl, ps = colorsys.rgb_to_hls(*rgb(c["primary"]))
amber = 42 / 360
dh = ((ph - amber + 0.5) % 1) - 0.5
warning = hexc(colorsys.hls_to_rgb((amber + dh * 0.15) % 1, 0.72 if dark else 0.42, max(ps, 0.75)))

theme = {
    "base": "dark" if dark else "light",
    "colors": {
        "window": "#" + c["surface"],
        "panel": "#" + c["surfaceContainerLow"],
        "surface": "#" + c["surfaceContainer"],
        "surface_hover": "#" + c["surfaceContainerHigh"],
        "surface_active": "#" + c["surfaceContainerHighest"],
        "outline": "#" + c["outlineVariant"],
        "text": "#" + c["onSurface"],
        "secondary": "#" + c["onSurfaceVariant"],
        "dim": "#" + c["outline"],
        "accent": "#" + c["primary"],
        "accent_hover": mix(c["primary"], "ffffff" if dark else "000000", 0.2),
        "on_accent": "#" + c["onPrimary"],
        "danger": "#" + c["error"],
        "warning": warning,
        "overlay": "#" + c["surfaceContainerLow"],
        "bubble_in": "#" + c["surfaceContainerHighest"],
        "bubble_out": "#" + c["primaryContainer"],
    },
}
json.dump(theme, sys.stdout, indent=2)
print()
EOF

mv "$tmp" "$THEME_FILE"
trap - EXIT
echo "Wrote $THEME_FILE"

if pgrep -x zapfast >/dev/null; then
	zapfast reload-themes
fi
