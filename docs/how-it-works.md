# How it works

## `./install`

1. Initializes the `dotbot` submodule (pinned to a release tag).
2. Runs Dotbot on the **public** layer, `install.conf.yaml`.
3. Tries `git submodule update --init personal`. If that works and
   `personal/install.conf.yaml` exists, runs that layer too.
4. With `work`, does the same for `picpay`.

Dotbot runs with `-x`: the first failing step stops the run with a non-zero
exit, and the steps after it don't run.

## Inside a layer

Directives run top to bottom:

- `defaults`: links create parent directories and replace stale links; shell
  steps show their output.
- `clean`: removes dead symlinks that point into the repo.
- `link`: creates symlinks. This runs **before** the installers so oh-my-zsh
  finds our `~/.zshrc` and keeps it.
- `shell`: runs `scripts/*.sh` one by one, in order.

## Writing an install script

```bash
#!/usr/bin/env bash
source "$(dirname -- "${BASH_SOURCE[0]}")/lib.sh"   # set -euo pipefail, helpers
skip_if_installed mytool                            # exit 0 if already there

curl -fsSL https://example.com/install.sh | sh
has mytool || { log "install failed" >&2; exit 1; }
```

`lib.sh` provides `log`, `has`, `is_linux`, `is_macos` and `skip_if_installed`,
puts `~/.local/bin` on `PATH`, and sets `USER` when it's missing.

Keep each tool in its own script so a changed installer is a one-file fix. Pin a
version when the installer supports it (see `NERD_FONTS_VERSION` in `fonts.sh`).

## Link files, not folders, when a tool writes next to its config

herdr writes sockets, logs and sessions into `~/.config/herdr/`. Linking the
whole folder would put them in the repo, so the personal layer links only
`~/.config/herdr/config.toml`.

## Tests

`tests/run_tests.sh` (or `make test`) builds `tests/docker/ubuntu-*/Dockerfile`.
Each image has only sudo, git, python3 and certificates, plus the stock `ubuntu`
user with passwordless sudo. Then it runs `tests/smoke.sh` inside:

1. Clones committed HEAD from the read-only mount (`WORKTREE=1` copies the
   working tree instead). Private submodules are cloned from the host's checkout.
2. Runs `./install` twice. Both runs must exit 0.
3. Checks tools, symlinks, login shell, and `zsh -i -c exit` with empty stderr.

Docker can't run macOS. Use a GitHub Actions `macos-latest` runner, or Tart on an
Apple Silicon Mac.
