#!/usr/bin/env zsh 

DOTFILES_PATH="$HOME/dotfiles"

function main {
	local stow_folders=(vim zsh)

	pushd "$DOTFILES_PATH"

	for folder in "$stow_folders[@]"; do 
		echo "  - Removing: '$folder'"

		stow -D "$folder"
	done
}

main "$@"

