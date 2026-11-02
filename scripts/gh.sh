#!/usr/bin/env bash
# GitHub CLI, from GitHub's apt repository (https://cli.github.com).
source "$(dirname -- "${BASH_SOURCE[0]}")/lib.sh"
skip_if_installed gh

if is_macos; then
	brew install --quiet gh
else
	add_apt_repo github-cli https://cli.github.com/packages/githubcli-archive-keyring.gpg \
		"deb [arch=$(dpkg --print-architecture) signed-by=KEYRING] https://cli.github.com/packages stable main"
	apt_install gh
fi
has gh || { log "install failed" >&2; exit 1; }
