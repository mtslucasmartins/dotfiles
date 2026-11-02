#!/usr/bin/env bash
# AWS CLI v2. Linux: AWS's official zip installer (/usr/local/aws-cli,
# /usr/local/bin/aws). Upgrade by re-running it with --update.
source "$(dirname -- "${BASH_SOURCE[0]}")/lib.sh"
skip_if_installed aws

if is_macos; then
	brew install --quiet awscli
else
	case "$(uname -m)" in
		x86_64|amd64) arch=x86_64 ;;
		aarch64|arm64) arch=aarch64 ;;
		*) log "unsupported architecture: $(uname -m)" >&2; exit 1 ;;
	esac
	tmp="$(mktemp -d)"
	curl -fsSL --retry 3 -o "$tmp/awscli.zip" "https://awscli.amazonaws.com/awscli-exe-linux-$arch.zip"
	unzip -q "$tmp/awscli.zip" -d "$tmp"
	sudo "$tmp/aws/install"
	rm -rf "$tmp"
fi
has aws || { log "install failed" >&2; exit 1; }
