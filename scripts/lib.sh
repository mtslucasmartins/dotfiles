# Shared helpers, sourced by the install scripts.
# shellcheck shell=bash

set -euo pipefail

# Tools installed per-user land here; make them visible during install too.
export PATH="$HOME/.local/bin:$PATH"

function log  { printf '  [%s] %s\n' "${SCRIPT_NAME:-${0##*/}}" "$*"; }
function has  { command -v "$1" >/dev/null 2>&1; }
function is_macos { [[ $(uname -s) == Darwin ]]; }
function is_linux { [[ $(uname -s) == Linux ]]; }

# Exit 0 early when a tool is already present (keeps re-runs cheap).
function skip_if_installed {
	if has "$1"; then
		log "$1 already installed ($(command -v "$1")), skipping"
		exit 0
	fi
}

# $USER isn't always set (containers, cron); fall back to the real account.
export USER="${USER:-$(id -un)}"

# add_apt_repo NAME KEY_URL "deb ... " — adds a signed apt repository once.
# Use "[signed-by=KEYRING]" in the deb line; it's replaced with the key's path.
# Text keys are saved as .asc and binary ones as .gpg, so apt reads either
# without needing gpg installed.
function add_apt_repo {
	local name="$1" key_url="$2" line="$3" tmp keyring
	[[ -f /etc/apt/sources.list.d/$name.list ]] && return 0

	tmp="$(mktemp)"
	curl -fsSL --retry 3 -o "$tmp" "$key_url"
	if head -c 5 "$tmp" | grep -q -- '-----'; then
		keyring="/etc/apt/keyrings/$name.asc"
	else
		keyring="/etc/apt/keyrings/$name.gpg"
	fi
	sudo install -D -m 0644 "$tmp" "$keyring"
	rm -f "$tmp"

	echo "${line//KEYRING/$keyring}" | sudo tee "/etc/apt/sources.list.d/$name.list" >/dev/null
	sudo apt-get update -qq
}

# apt_install PKG... — quiet, non-interactive install.
function apt_install {
	sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq --no-install-recommends "$@" >/dev/null
}
