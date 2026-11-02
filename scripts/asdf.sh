#!/usr/bin/env bash
# asdf (version manager) plus every tool in ~/.tool-versions (asdf/.tool-versions).
# To add a language: add its plugin below and a line to asdf/.tool-versions.
source "$(dirname -- "${BASH_SOURCE[0]}")/lib.sh"

readonly ASDF_VERSION="${ASDF_VERSION:-v0.20.2}"
export ASDF_DATA_DIR="${ASDF_DATA_DIR:-$HOME/.asdf}"
export PATH="$ASDF_DATA_DIR/shims:$PATH"

# "name url" — URLs match what `asdf plugin list --urls` shows on the main machine.
readonly PLUGINS=(
	"java https://github.com/halcyon/asdf-java.git"
	"maven https://github.com/halcyon/asdf-maven.git"
	"nodejs https://github.com/asdf-vm/asdf-nodejs.git"
	"python https://github.com/danhper/asdf-python.git"
	"rust https://github.com/asdf-community/asdf-rust.git"
	"uv https://github.com/asdf-community/asdf-uv.git"
)

if has asdf; then
	log "asdf already installed ($(asdf --version)), skipping binary"
else
	case "$(uname -m)" in
		x86_64|amd64) arch=amd64 ;;
		aarch64|arm64) arch=arm64 ;;
		*) log "unsupported architecture: $(uname -m)" >&2; exit 1 ;;
	esac
	os="$(uname -s | tr '[:upper:]' '[:lower:]')"
	log "installing asdf $ASDF_VERSION ($os-$arch)"
	mkdir -p "$HOME/.local/bin"
	curl -fsSL --retry 3 \
		"https://github.com/asdf-vm/asdf/releases/download/$ASDF_VERSION/asdf-$ASDF_VERSION-$os-$arch.tar.gz" \
		| tar -xz -C "$HOME/.local/bin" asdf
fi

# zsh completions (~/.zshrc puts this folder on fpath).
mkdir -p "$ASDF_DATA_DIR/completions"
asdf completion zsh > "$ASDF_DATA_DIR/completions/_asdf"

installed_plugins="$(asdf plugin list 2>/dev/null || true)"
for entry in "${PLUGINS[@]}"; do
	name="${entry%% *}"
	url="${entry#* }"
	if grep -qx "$name" <<< "$installed_plugins"; then
		log "plugin $name already added"
	else
		log "adding plugin $name"
		asdf plugin add "$name" "$url"
	fi
done

# Installs every version in ~/.tool-versions; already-installed ones are skipped.
log "installing tool versions (python builds from source; first run is slow)"
cd "$HOME"
asdf install
asdf reshim
