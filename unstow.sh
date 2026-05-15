#!/usr/bin/env zsh

DOTFILES_PATH="${DOTFILES_PATH:-${0:A:h}}"

typeset -g INCLUDE_PERSONAL=1
typeset -g INCLUDE_WORK=0

function usage {
	print -r -- 'Usage: zsh unstow.sh [options]'
	print -r -- ''
	print -r -- '  (default)      Remove public + personal symlinks (when submodule scripts exist).'
	print -r -- '  --no-personal  Only remove public packages.'
	print -r -- '  --work         Also remove PicPay work submodule symlinks.'
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

function unstow_picpay {
	local ws="$DOTFILES_PATH/picpay/unstow.sh"
	if [[ -f $ws ]]; then
		bash "$ws"
		return
	fi
	local ss="$DOTFILES_PATH/picpay/stow.sh"
	if [[ ! -f $ss ]]; then
		print -r -- 'PicPay: no unstow.sh or stow.sh (skip).'
		return 0
	fi
	print -r -- 'PicPay: picpay/unstow.sh not found; remove work symlinks manually if needed.' >&2
}

function unstow_personal {
	local pu="$DOTFILES_PATH/personal/unstow.sh"
	if [[ ! -f $pu ]]; then
		print -r -- 'Personal unstow script missing (skip).'
		return 0
	fi
	print -r -- 'Removing personal submodule symlinks:'
	bash "$pu"
}

function unstow_public {
	print -r -- 'Removing public dotfiles: vim, tmux, zsh'
	( cd "$DOTFILES_PATH" || exit 1
		for folder in vim tmux zsh; do
			print -r -- "  - Removing: '$folder'"
			stow -D "$folder"
		done
	)
}

function main {
	parse_args "$@"
	if [[ $INCLUDE_WORK -eq 1 ]]; then
		unstow_picpay
	fi
	if [[ $INCLUDE_PERSONAL -eq 1 ]]; then
		unstow_personal
	fi
	unstow_public
}

main "$@"
