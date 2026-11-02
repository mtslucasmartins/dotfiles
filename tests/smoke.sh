#!/usr/bin/env bash
# Runs INSIDE the test container. Gets the repo into ~/dotfiles the way a new
# machine would, runs the install entry point twice, then checks the result.
#
# Env (set by run_tests.sh, or by CI when run directly on a macOS runner):
#   SOURCE  commit | worktree   what to test (default: commit)
#   ENTRY   install command, run from the repo root (default: ./install)
#   SRC     repo to test (default: /src, the container mount)

set -uo pipefail

readonly SRC="${SRC:-/src}"
readonly DEST="$HOME/dotfiles"
readonly SOURCE="${SOURCE:-commit}"
readonly ENTRY="${ENTRY:-./install}"

readonly GREEN=$'\033[32m' RED=$'\033[31m' BOLD=$'\033[1m' RESET=$'\033[0m'
passed=0
failed=0

function step { printf '\n%s==> %s%s\n' "$BOLD" "$1" "$RESET"; }
function ok   { printf '%sPASS%s %s\n' "$GREEN" "$RESET" "$1"; passed=$((passed + 1)); }
function ko   { printf '%sFAIL%s %s\n' "$RED" "$RESET" "$1"; failed=$((failed + 1)); }

function check {
	local description="$1"
	shift
	if "$@" >/dev/null 2>&1; then ok "$description"; else ko "$description"; fi
}

function get_repo {
	if [[ $SOURCE == worktree ]]; then
		step "Copying working tree (includes uncommitted changes)"
		mkdir -p "$DEST"
		# Sockets and other special files are skipped by tar with a warning.
		tar -C "$SRC" -cf - . 2>/dev/null | tar -C "$DEST" -xf -
	else
		step "Cloning committed HEAD (uncommitted changes are NOT tested)"
		git clone --quiet "$SRC" "$DEST" || return 1
		# Submodules use SSH URLs, which can't work here. Point the ones that are
		# checked out on the host at their local copy; others stay unreachable.
		git -C "$DEST" submodule init >/dev/null 2>&1
		local path
		while read -r _ path; do
			# A checked-out submodule has its own .git file; an empty dir doesn't.
			if [[ -e "$SRC/$path/.git" ]]; then
				git -C "$DEST" config "submodule.$path.url" "$SRC/$path"
				echo "  submodule '$path' -> local copy"
			else
				echo "  submodule '$path' not checked out on host (skipped)"
			fi
		done < <(git -C "$DEST" config -f .gitmodules --get-regexp '\.path$')
	fi
}

function run_install {
	local label="$1"
	step "$label: $ENTRY"
	if (cd "$DEST" && eval "$ENTRY"); then
		ok "$label succeeded."
	else
		ko "$label succeeded."
	fi
}

# Runs a command in an interactive zsh, so PATH, asdf shims and ~/.zshrc are
# exactly what you'd have in a terminal.
function in_zsh { zsh -i -c "$1" </dev/null >/dev/null 2>&1; }

# tool NAME COMMAND -> "PASS NAME is installed."
function tool {
	if in_zsh "$2"; then ok "$1 is installed."; else ko "$1 is installed."; fi
}

function verify {
	step "Verifying result"

	tool zsh        'zsh --version'
	tool oh-my-zsh  '[[ -f $ZSH/oh-my-zsh.sh ]]'
	tool starship   'starship --version'
	tool herdr      'herdr --version'
	echo

	tool git        'git --version'
	tool curl       'curl --version'
	tool vim        'vim --version'
	tool tree       'tree --version'
	tool jq         'jq --version'
	echo

	tool golang     '/usr/local/go/bin/go version'
	tool asdf       'asdf --version'
	tool python     'asdf which python && python --version'
	tool java       'asdf which java && java -version'
	tool maven      'asdf which mvn && mvn -v'
	tool node       'asdf which node && node --version'
	tool uv         'asdf which uv && uv --version'
	tool rust       'asdf which rustc && rustc --version'
	tool cargo      'asdf which cargo && cargo --version'
	echo

	check "~/.zshrc is linked."        test -L "$HOME/.zshrc"
	check "~/.vimrc is linked."        test -L "$HOME/.vimrc"
	check "~/.tmux.conf is linked."    test -L "$HOME/.tmux.conf"
	check "~/.tool-versions is linked." test -L "$HOME/.tool-versions"
	if [[ $(uname -s) == Darwin ]]; then
		check "A Nerd Font is installed." bash -c 'ls ~/Library/Fonts/*/*NerdFont* >/dev/null 2>&1'
		check "zsh is the login shell."   bash -c 'dscl . -read "/Users/$(id -un)" UserShell | grep -q zsh'
	else
		check "A Nerd Font is installed." bash -c 'fc-list 2>/dev/null | grep -qi nerd'
		check "zsh is the login shell."   bash -c 'getent passwd "$(id -un)" | cut -d: -f7 | grep -q zsh'
	fi

	if command -v zsh >/dev/null 2>&1; then
		local err
		err="$(zsh -i -c exit </dev/null 2>&1 >/dev/null)"
		if [[ -z $err ]]; then
			ok "zsh starts without errors."
		else
			ko "zsh starts without errors."
			printf '%s\n' "$err" | sed 's/^/     /'
		fi
	else
		ko "zsh starts without errors."
	fi
}

function main {
	get_repo || { ko "getting the repo"; exit 1; }

	# A missing entry point is a setup problem, not 11 separate failures.
	local entry_cmd="${ENTRY%% *}"
	if [[ $entry_cmd == ./* && ! -e "$DEST/$entry_cmd" ]]; then
		ko "entry point '$entry_cmd' not found in the repo"
		echo "       Commit it (or use --worktree), or pick another with --entry / ENTRY=..."
		exit 1
	fi

	run_install "First install"
	run_install "Second install (idempotency)"
	verify

	printf '\n%s%d passed, %d failed%s\n' "$BOLD" "$passed" "$failed" "$RESET"
	((failed == 0))
}

main "$@"
