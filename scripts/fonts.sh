#!/usr/bin/env bash
# Nerd Fonts from the official releases. Pinned: bump NERD_FONTS_VERSION on purpose.
source "$(dirname -- "${BASH_SOURCE[0]}")/lib.sh"

readonly NERD_FONTS_VERSION="${NERD_FONTS_VERSION:-v3.4.0}"
readonly FONTS=(CodeNewRoman Ubuntu)

if is_macos; then
	readonly TARGET="$HOME/Library/Fonts"
else
	readonly TARGET="${XDG_DATA_HOME:-$HOME/.local/share}/fonts"
fi

installed_any=0
for font in "${FONTS[@]}"; do
	dir="$TARGET/$font"
	if [[ -d $dir ]] && compgen -G "$dir/*.[ot]tf" >/dev/null; then
		log "$font already installed, skipping"
		continue
	fi
	log "installing $font ($NERD_FONTS_VERSION)"
	tmp="$(mktemp -d)"
	curl -fsSL --retry 3 -o "$tmp/$font.zip" \
		"https://github.com/ryanoasis/nerd-fonts/releases/download/$NERD_FONTS_VERSION/$font.zip"
	mkdir -p "$dir"
	unzip -q -o "$tmp/$font.zip" '*.ttf' '*.otf' -d "$dir" 2>/dev/null || true
	rm -rf "$tmp"
	installed_any=1
done

if ((installed_any)) && has fc-cache; then
	fc-cache -f "$TARGET" >/dev/null
fi
