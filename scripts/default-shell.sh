#!/usr/bin/env bash
# Make zsh the login shell (takes effect on next login).
source "$(dirname -- "${BASH_SOURCE[0]}")/lib.sh"

has zsh || { log "zsh not installed" >&2; exit 1; }
zsh_path="$(command -v zsh)"
if is_macos; then
	current="$(dscl . -read "/Users/$USER" UserShell | awk '{print $2}')"
else
	current="$(getent passwd "$USER" | cut -d: -f7)"
fi

if [[ $current == "$zsh_path" ]]; then
	log "already zsh, skipping"
	exit 0
fi

grep -qxF "$zsh_path" /etc/shells || echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
sudo chsh -s "$zsh_path" "$USER"
log "login shell set to $zsh_path (log out and back in)"
