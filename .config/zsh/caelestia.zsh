# Re-check dotfiles links and re-apply theme hooks after `caelestia update`
caelestia() {
	command caelestia "$@" || return
	if [[ "$1" == update ]]; then
		~/.local/bin/posthooks/caelestia-post-update.sh
	fi
}
