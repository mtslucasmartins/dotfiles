# How this dotfiles repository works

This document describes how the repo is laid out, how “installation” works (via GNU Stow), and what happens when you run the scripts.

## Mental model (which machine runs what)

| Layer | Where | Purpose |
|--------|--------|--------|
| **Public** | This repo, top-level packages (`vim`, `tmux`, `zsh`) | Same on **every** PC — run root `stow.sh`. |
| **Personal** | `personal/` git submodule | Private overlays (`~/.config/personal/`). Linked automatically when the submodule is present; no need to `cd` into `personal/`. |
| **PicPay (work)** | `picpay/` git submodule | **Only work machines.** Pass **`--work`** to root `stow.sh` / `unstow.sh` so PicPay runs **after** public + personal (work wins on overlapping paths). |

Submodules you never initialize simply stay absent; scripts skip them.

## Prerequisites

1. **GNU Stow** — e.g. `brew install stow` (macOS) or `apt install stow` (Debian/Ubuntu).
2. **Repo path** — `DOTFILES_PATH` defaults to the directory that contains `stow.sh` (the repo root). Override with `DOTFILES_PATH=/path/to/repo zsh stow.sh` if needed.
3. **Oh My Zsh** — `zsh/.zshrc` expects `$HOME/.oh-my-zsh`. Install separately if you use this `.zshrc`.

## First-time clone

```sh
git clone <this-repo> ~/dotfiles   # path is arbitrary now
cd ~/dotfiles
git submodule update --init personal              # personal machines
git submodule update --init personal picpay      # work machine (both submodules)
```

You can init only the submodules you need (`personal` without `picpay` on non-work PCs).

## One command from the repo root: `zsh stow.sh`

Default behavior:

1. Stow **public** packages: `vim`, `tmux`, `zsh` → `$HOME`.
2. If `personal/stow.sh` exists (submodule checked out), run it → `~/.config/personal/`.
3. **PicPay** runs only with **`--work`** (see below).

**Options**

- `--no-personal` — public only (CI, minimal box, or debugging).
- `--work` — after public (+ personal unless `--no-personal`), run **`picpay/stow.sh`** if it exists. The PicPay submodule should ship a `stow.sh` at its root (same idea as `personal/stow.sh`).
- `-h` / `--help`

**Overlay order:** public → personal → PicPay (`--work`). That way work-specific files override personal/public where paths overlap.

### PicPay repo expectations

On work machines you maintain **`picpay/stow.sh`** (and preferably **`picpay/unstow.sh`**) inside the PicPay submodule. Root `unstow.sh --work` calls `picpay/unstow.sh` when present; otherwise it warns that manual cleanup may be needed.

## `zsh unstow.sh`

Removes symlinks in reverse-ish layers:

- With **`--work`**: runs **`picpay/unstow.sh`** if present.
- Unless **`--no-personal`**: runs **`personal/unstow.sh`** (removes `config` from `$HOME`).
- Always: **`stow -D`** for **`vim`**, **`tmux`**, **`zsh`** (matches full public install).

Same flags as `stow.sh`: `--no-personal`, `--work`, `-h` / `--help`.

## Submodule paths (`personal/stow.sh`)

`personal/stow.sh` lives in the submodule but resolves the repo root from its own location (`../`), then stows package **`config`** with `--target="$HOME"` so `personal/config/.config/personal/...` becomes `~/.config/personal/...`.

That matches `zsh/.zshrc`:

```17:17:zsh/.zshrc
source "$HOME/.config/personal/index"
```

`personal/index` sources other files under `~/.config/personal/` (e.g. `paths`, `env`, `aliases`). Ensure anything referenced there exists on disk.

## Other directories (not wired into `stow.sh`)

- **`vscode/`** — settings JSON in-repo; link or copy manually if you want.
- **`themes/`** — terminal theme; same.

## `personal/scripts/install-tools.sh`

Placeholder script (prints tool names only); not called by root `stow.sh`.

## Summary checklist

1. Install **Stow** (and **Oh My Zsh** if needed).
2. Clone repo (any path).
3. `git submodule update --init personal` (and `picpay` only on work machines).
4. **Personal / non-work:** `zsh stow.sh`
5. **Work machine:** `zsh stow.sh --work`
6. Public-only box: `zsh stow.sh --no-personal`

You no longer need to run `bash personal/stow.sh` by hand unless you prefer to; root `stow.sh` delegates to it when the submodule is present.
