#!/usr/bin/env bash
# CI only: clone the private personal submodule with a read-only deploy key.
# The key is written to a temp file and deleted right after the clone.
set -euo pipefail

if [[ -z ${DEPLOY_KEY:-} ]]; then
	echo "::error::Secret PERSONAL_DOTFILES_DEPLOY_KEY is not set, so the personal layer can't be tested. See the comment at the top of .github/workflows/test.yml."
	exit 1
fi

key="$(mktemp)"
trap 'rm -f "$key"' EXIT
printf '%s\n' "$DEPLOY_KEY" > "$key"
chmod 600 "$key"

GIT_SSH_COMMAND="ssh -i $key -o IdentitiesOnly=yes -o StrictHostKeyChecking=accept-new" \
	git submodule update --init personal
git -C personal log --oneline -1
