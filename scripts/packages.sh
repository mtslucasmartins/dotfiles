#!/usr/bin/env bash
# Base system packages. Everything else builds on these.
source "$(dirname -- "${BASH_SOURCE[0]}")/lib.sh"

readonly APT_PACKAGES=(
	zsh git curl ca-certificates unzip fontconfig vim tmux tree jq
	# asdf python builds from source and needs these:
	build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev
	libncurses-dev xz-utils tk-dev libxml2-dev libffi-dev liblzma-dev
)
readonly BREW_PACKAGES=(zsh git curl vim tmux tree jq openssl readline sqlite3 xz zlib tcl-tk)

if is_linux && has apt-get; then
	missing=()
	for pkg in "${APT_PACKAGES[@]}"; do
		dpkg-query -W -f='${Status}' "$pkg" 2>/dev/null | grep -q 'install ok installed' || missing+=("$pkg")
	done
	if ((${#missing[@]} == 0)); then
		log "all packages present, skipping"
		exit 0
	fi
	log "installing: ${missing[*]}"
	sudo apt-get update -qq
	sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq --no-install-recommends "${missing[@]}" >/dev/null
elif is_macos; then
	if ! has brew; then
		log "installing Homebrew"
		NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
		eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"
	fi
	brew install --quiet "${BREW_PACKAGES[@]}"
else
	log "unsupported system: $(uname -s) (need apt or macOS)" >&2
	exit 1
fi
