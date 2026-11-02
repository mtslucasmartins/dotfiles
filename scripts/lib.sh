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
