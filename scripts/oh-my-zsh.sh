#!/usr/bin/env bash
# https://ohmyz.sh — keep our ~/.zshrc, don't switch shell or start zsh.
source "$(dirname -- "${BASH_SOURCE[0]}")/lib.sh"

if [[ -d $HOME/.oh-my-zsh ]]; then
	log "already installed, skipping"
	exit 0
fi

RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
