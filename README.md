# Dotfiles

Clone and run one command; [Dotbot](https://github.com/anishathalye/dotbot) links
the configs and installs the tools.

```sh
git clone https://github.com/mtslucasmartins/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install                # public + personal layers
./install work           # also the PicPay work layer
./install --public-only  # skip the private layers
```

Needs only `git` and `python3`, which a fresh Ubuntu already has (on macOS, the
Xcode Command Line Tools provide both). Re-running is safe: every step skips what's
already done.

## Layers

| Layer | Config | Runs |
|---|---|---|
| Public | `install.conf.yaml` | always |
| Personal | `personal/install.conf.yaml` (private submodule) | always, unless `--public-only` |
| Work | `picpay/install.conf.yaml` (private submodule) | with `./install work` |

Later layers win where paths overlap. The private submodules use SSH. On a new
machine without a key on GitHub, the public layer still installs, then
`./install` stops with an error that shows how to add a key. Re-run it afterwards.

## What gets installed

One script per tool in `scripts/`, run in order by `install.conf.yaml`:

| Script | Installs |
|---|---|
| `packages.sh` | zsh, git, curl, vim, tmux, tree, jq, unzip, fontconfig, Python build deps (apt / Homebrew) |
| `oh-my-zsh.sh` | Oh My Zsh (keeps our `~/.zshrc`) |
| `starship.sh` | Starship → `~/.local/bin` |
| `fonts.sh` | Nerd Fonts (CodeNewRoman, Ubuntu), pinned by `NERD_FONTS_VERSION` |
| `herdr.sh` | herdr → `~/.local/bin` (upgrade with `herdr update`) |
| `golang.sh` | Go → `/usr/local/go`, pinned by `GO_VERSION` |
| `asdf.sh` | asdf, its plugins, and every version in `asdf/.tool-versions` (java, maven, nodejs, python, rust/cargo, uv) |
| `gh.sh`, `gcloud.sh`, `heroku.sh` | GitHub, Google Cloud and Heroku CLIs from their official apt repos (Homebrew on macOS) |
| `awscli.sh` | AWS CLI v2 from AWS's official installer (Homebrew on macOS) |
| `default-shell.sh` | Sets zsh as the login shell |

To add a tool: write `scripts/<tool>.sh` (start with `source .../lib.sh` and
`skip_if_installed <tool>`), then add a line to the `shell:` list.

## Testing

Runs the whole bootstrap in fresh Ubuntu containers (needs Docker):

```sh
make test                          # ubuntu:24 and ubuntu:26, committed HEAD
make test TARGET=ubuntu:26         # one target
make test WORKTREE=1               # include uncommitted changes
make test TARGET=ubuntu:24 DEBUG=1 # shell into the container afterwards
```

Each run installs twice (the second run must change nothing), then checks the
tools, symlinks, login shell, that every alias in the personal aliases file is
defined in zsh, and that zsh starts without errors.

CI (`.github/workflows/test.yml`) runs the same test on Ubuntu 24.04, Ubuntu
26.04 and macOS in parallel on every push. It fetches the personal submodule
with a read-only deploy key stored in the `PERSONAL_DOTFILES_DEPLOY_KEY` secret. macOS can't
run in Docker; see `docs/how-it-works.md`.

## Not wired in

`vscode/` and `themes/` are kept in the repo but not linked; copy them manually.

## Roadmap

- **Secrets:** keep untracked `{profile}/secrets/.env.secrets`, with a
  `make check-secrets` that compares it against a tracked `.env.secrets.template`.
- **macOS CI:** a GitHub Actions `macos-latest` job running `./install`.
