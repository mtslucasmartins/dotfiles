#!/usr/bin/env bash
# CI only: clone the private personal submodule with a read-only deploy key.
# The key is written to a temp file and deleted right after the clone.
# Errors are emitted as ::error annotations so they show on the run summary.
set -uo pipefail

function fail {
	echo "::error title=Fetch personal submodule::$1"
	exit 1
}

[[ -n ${DEPLOY_KEY:-} ]] || fail "Secret PERSONAL_DOTFILES_DEPLOY_KEY is not set. See the comment at the top of .github/workflows/test.yml."

key="$(mktemp)"
trap 'rm -f "$key"' EXIT
# Normalize line endings in case the secret was pasted with CRLF.
printf '%s\n' "$DEPLOY_KEY" | tr -d '\r' > "$key"
chmod 600 "$key"

if grep -q '^ssh-' "$key"; then
	fail "PERSONAL_DOTFILES_DEPLOY_KEY holds a PUBLIC key (ssh-ed25519 ...). The secret needs the private file (without .pub); the .pub goes in personal-dotfiles' deploy keys."
fi
grep -q -- '-----BEGIN .*PRIVATE KEY-----' "$key" \
	|| fail "PERSONAL_DOTFILES_DEPLOY_KEY doesn't look like a private key. Paste the whole private key file, including the BEGIN and END lines."

# The fingerprint is public information: compare it with the one GitHub lists
# under personal-dotfiles -> Settings -> Deploy keys.
if ! fingerprint="$(ssh-keygen -lf "$key" 2>&1)"; then
	fail "PERSONAL_DOTFILES_DEPLOY_KEY isn't a valid private key (ssh-keygen: ${fingerprint}). Paste the whole private key file, including the BEGIN and END lines."
fi
echo "Deploy key fingerprint: $fingerprint"

export GIT_SSH_COMMAND="ssh -i $key -o IdentitiesOnly=yes -o StrictHostKeyChecking=accept-new"
if ! out="$(git submodule update --init personal 2>&1)"; then
	echo "$out"
	hint=""
	if grep -q 'Permission denied (publickey)' <<< "$out"; then
		hint=" GitHub rejected the key: add its public half as a deploy key on personal-dotfiles, or make sure the secret holds the matching private key (fingerprint ${fingerprint%% (*})."
	elif grep -q 'not our ref\|unadvertised object' <<< "$out"; then
		hint=" The commit dotfiles points at isn't on personal-dotfiles: push personal first."
	fi
	fail "Cloning personal failed: $(tail -n 1 <<< "$out").${hint}"
fi
git -C personal log --oneline -1
