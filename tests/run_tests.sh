#!/usr/bin/env bash
# Tests the dotfiles bootstrap on fresh Ubuntu containers.
#
#   tests/run_tests.sh                               # all targets
#   tests/run_tests.sh --target=ubuntu:24
#   tests/run_tests.sh --target=ubuntu:24,ubuntu:26
#   tests/run_tests.sh --target=ubuntu:26 --worktree --shell

set -uo pipefail

readonly TESTS_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_DIR="$(dirname -- "$TESTS_DIR")"
readonly ALL_TARGETS=(ubuntu:24 ubuntu:26)

targets=()
source_mode=commit
entry=./install
open_shell=0

function usage {
	cat <<'EOF'
Usage: tests/run_tests.sh [options]

  --target=T[,T...]  ubuntu:24, ubuntu:26 (default: all). Repeatable.
  --worktree         Test the working tree, including uncommitted changes.
                     Default tests committed HEAD, like a real `git clone`.
  --entry=CMD        Install command run from the repo root (default: ./install).
  --shell            Open a shell in the container after the tests (debugging).
  -h, --help         Show this help.
EOF
}

# ubuntu:24 -> ubuntu-24.04 (folder under tests/docker/)
function target_dir {
	case "$1" in
		ubuntu:24|ubuntu:24.04) echo ubuntu-24.04 ;;
		ubuntu:26|ubuntu:26.04) echo ubuntu-26.04 ;;
		*) return 1 ;;
	esac
}

function parse_args {
	local arg t
	for arg in "$@"; do
		case $arg in
			--target=*)
				IFS=',' read -r -a t <<< "${arg#--target=}"
				targets+=("${t[@]}")
				;;
			--worktree) source_mode=worktree ;;
			--entry=*) entry="${arg#--entry=}" ;;
			--shell) open_shell=1 ;;
			-h|--help) usage; exit 0 ;;
			*) echo "Unknown option: $arg" >&2; usage >&2; exit 2 ;;
		esac
	done
	((${#targets[@]})) || targets=("${ALL_TARGETS[@]}")

	for t in "${targets[@]}"; do
		target_dir "$t" >/dev/null || { echo "Unknown target: $t (valid: ${ALL_TARGETS[*]})" >&2; exit 2; }
	done
}

function run_target {
	local target="$1" dir image
	dir="$(target_dir "$target")"
	image="dotfiles-test:$dir"

	printf '\n\033[1m######## %s (%s) ########\033[0m\n' "$target" "$source_mode"

	docker build --quiet -t "$image" "$TESTS_DIR/docker/$dir" >/dev/null || {
		echo "Image build failed for $target" >&2
		return 1
	}

	local cmd='bash /src/tests/smoke.sh'
	((open_shell)) && cmd+='; status=$?; echo; echo "Opening shell (exit to finish)"; bash; exit $status'

	local -a tty=()
	[[ -t 0 && -t 1 ]] && tty=(-it)
	((open_shell)) && ((${#tty[@]} == 0)) && { echo "--shell needs an interactive terminal" >&2; return 1; }

	docker run --rm "${tty[@]}" \
		-v "$REPO_DIR:/src:ro" \
		-e SOURCE="$source_mode" \
		-e ENTRY="$entry" \
		"$image" bash -c "$cmd"
}

function main {
	parse_args "$@"
	command -v docker >/dev/null || { echo "docker is required" >&2; exit 1; }

	local -a results=()
	local target status=0
	for target in "${targets[@]}"; do
		if run_target "$target"; then
			results+=("PASS  $target")
		else
			results+=("FAIL  $target")
			status=1
		fi
	done

	printf '\n\033[1mSummary\033[0m\n'
	printf '  %s\n' "${results[@]}"
	exit $status
}

main "$@"
