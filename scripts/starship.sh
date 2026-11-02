#!/usr/bin/env bash
# https://starship.rs — installed per-user into ~/.local/bin (no sudo).
source "$(dirname -- "${BASH_SOURCE[0]}")/lib.sh"
skip_if_installed starship

mkdir -p "$HOME/.local/bin"
curl -fsSL https://starship.rs/install.sh | sh -s -- --yes --bin-dir "$HOME/.local/bin" >/dev/null
has starship || { log "install failed" >&2; exit 1; }
