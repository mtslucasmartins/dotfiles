#!/usr/bin/env zsh

# Repo root (directory containing this script)
DOTFILES_PATH="${DOTFILES_PATH:-${0:A:h}}"

typeset -g INCLUDE_PERSONAL=1
typeset -g INCLUDE_WORK=0

function usage {
	print -r -- 'Usage: zsh stow.sh [options]'
	print -r -- ''
	print -r -- '  (default)      Link public packages (vim, tmux, zsh) and personal'
	print -r -- '                 when the personal submodule is present.'
	print -r -- '  --no-personal  Skip personal submodule (only public dotfiles).'
	print -r -- '  --work         Also link PicPay work submodule (expects picpay/stow.sh).'
	print -r -- '  -h, --help     Show this help.'
}

function parse_args {
	while [[ -n $1 ]]; do
		case $1 in
			-h|--help)
				usage
				exit 0
				;;
			--no-personal)
				INCLUDE_PERSONAL=0
				;;
			--work)
				INCLUDE_WORK=1
				;;
			*)
				print -r -- "Unknown option: $1" >&2
				usage >&2
				exit 1
				;;
		esac
		shift
	done
}

function stow_public {
	print -r -- 'Public dotfiles (all machines): vim, tmux, zsh'
	( cd "$DOTFILES_PATH" || exit 1
		for folder in vim tmux zsh; do
			print -r -- "  - Linking: '$folder'"
			stow -D "$folder"
			stow "$folder"
		done
	)
}

function stow_personal {
	local ps="$DOTFILES_PATH/personal/stow.sh"
	if [[ ! -f $ps ]]; then
		print -r -- 'Personal submodule: not present (skip). Clone with: git submodule update --init personal'
		return 0
	fi
	print -r -- 'Personal submodule (~/.config/personal):'
	bash "$ps"
}

function stow_picpay {
	local ws="$DOTFILES_PATH/picpay/stow.sh"
	if [[ ! -f $ws ]]; then
		print -r -- 'PicPay work submodule: picpay/stow.sh missing — init submodule and add a stow script there, or skip --work.' >&2
		return 1
	fi
	print -r -- 'PicPay work dotfiles:'
	bash "$ws"
}

function main {
	parse_args "$@"
	stow_public
	if [[ $INCLUDE_PERSONAL -eq 1 ]]; then
		stow_personal
	fi
	# PicPay last so work-specific files override personal/public where paths overlap.
	if [[ $INCLUDE_WORK -eq 1 ]]; then
		stow_picpay
	fi
}

main "$@"
