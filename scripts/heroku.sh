#!/usr/bin/env bash
# Heroku CLI, from Heroku's apt repository (same source as their install-ubuntu.sh).
source "$(dirname -- "${BASH_SOURCE[0]}")/lib.sh"
skip_if_installed heroku

if is_macos; then
	brew install --quiet heroku/brew/heroku
else
	add_apt_repo heroku https://cli-assets.heroku.com/channels/stable/apt/release.key \
		"deb [signed-by=KEYRING] https://cli-assets.heroku.com/channels/stable/apt ./"
	apt_install heroku
fi
has heroku || { log "install failed" >&2; exit 1; }
