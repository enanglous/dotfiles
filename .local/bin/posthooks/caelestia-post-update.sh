#!/usr/bin/env bash
# Run after `caelestia update`: make sure our dotfiles symlinks survived,
# then re-apply the theme hooks with the current scheme.

set -euo pipefail

DOTS="$HOME/dotfiles"

# ensure_link <link path> <relative target>
ensure_link() {
	local link="$1" target="$2"
	if [[ -L "$link" && "$(readlink "$link")" == "$target" ]]; then
		return
	fi
	if [[ -e "$link" || -L "$link" ]]; then
		local bak="$link.caelestia-update.bak"
		echo "Warning: $link was replaced, moving it to $bak"
		rm -rf "$bak"
		mv "$link" "$bak"
	fi
	ln -s "$target" "$link"
	echo "Restored $link -> $target"
}

[[ -d "$DOTS" ]] || { echo "Dotfiles not found: $DOTS"; exit 1; }

ensure_link "$HOME/.config/caelestia/cli.json" "../../dotfiles/.config/caelestia/cli.json"
ensure_link "$HOME/.local/bin/posthook.sh" "../../dotfiles/.local/bin/posthook.sh"
ensure_link "$HOME/.local/bin/posthooks" "../../dotfiles/.local/bin/posthooks"

"$HOME/.local/bin/posthook.sh"
