#!/usr/bin/env bash
# Google Cloud CLI, from Google's apt repository.
source "$(dirname -- "${BASH_SOURCE[0]}")/lib.sh"
skip_if_installed gcloud

if is_macos; then
	brew install --quiet --cask gcloud-cli
else
	add_apt_repo google-cloud-sdk https://packages.cloud.google.com/apt/doc/apt-key.gpg \
		"deb [signed-by=KEYRING] https://packages.cloud.google.com/apt cloud-sdk main"
	apt_install google-cloud-cli
fi
has gcloud || { log "install failed" >&2; exit 1; }
