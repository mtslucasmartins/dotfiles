#!/usr/bin/env bash
# https://herdr.dev — official installer: ~/.local/bin, verifies sha256.
# Afterwards, upgrade with `herdr update`.
source "$(dirname -- "${BASH_SOURCE[0]}")/lib.sh"
skip_if_installed herdr

curl -fsSL https://herdr.dev/install.sh | sh
has herdr || { log "install failed" >&2; exit 1; }
