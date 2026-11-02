#!/usr/bin/env bash
# Go from the official tarball into /usr/local/go (on PATH via ~/.zshrc).
# Pinned: bump GO_VERSION on purpose; a different installed version is replaced.
source "$(dirname -- "${BASH_SOURCE[0]}")/lib.sh"

readonly GO_VERSION="${GO_VERSION:-1.27.3}"
readonly GO_ROOT=/usr/local/go

if [[ -x $GO_ROOT/bin/go ]] && "$GO_ROOT/bin/go" version | grep -q "go$GO_VERSION "; then
	log "go $GO_VERSION already installed, skipping"
	exit 0
fi

case "$(uname -m)" in
	x86_64|amd64) arch=amd64 ;;
	aarch64|arm64) arch=arm64 ;;
	*) log "unsupported architecture: $(uname -m)" >&2; exit 1 ;;
esac
os="$(uname -s | tr '[:upper:]' '[:lower:]')"

log "installing go $GO_VERSION ($os-$arch)"
tmp="$(mktemp -d)"
curl -fsSL --retry 3 -o "$tmp/go.tar.gz" "https://go.dev/dl/go$GO_VERSION.$os-$arch.tar.gz"
sudo rm -rf "$GO_ROOT"
sudo tar -C /usr/local -xzf "$tmp/go.tar.gz"
rm -rf "$tmp"
"$GO_ROOT/bin/go" version
