# Public Dotfiles

GNU **Stow** links configs into `$HOME`. Scripts live at the **repo root**; `DOTFILES_PATH` defaults to that directory (no need to clone to `~/dotfiles` unless you want to).

## Layers

- **Public** (`vim`, `tmux`, `zsh`) — every machine.
- **Personal** (`personal/` submodule) — linked automatically when the submodule exists.
- **PicPay work** (`picpay/` submodule) — only on work PCs; use `--work`.

## Requirements

Install Stow (e.g. macOS: `brew install stow`).

## Installing

From the repo root:

```sh
zsh stow.sh              # public + personal (if submodule checked out)
zsh stow.sh --no-personal    # public only
zsh stow.sh --work           # also link PicPay submodule (work machines)
```

Initialize submodules first, e.g.:

```sh
git submodule update --init personal
git submodule update --init personal picpay   # work machine
```

See **`docs/how-it-works.md`** for behavior and PicPay `stow.sh` expectations.

## Uninstalling

```sh
zsh unstow.sh
zsh unstow.sh --no-personal
zsh unstow.sh --work
```
--- 

## Required Changes

In order to get a better experience with this project, there are a few things we need to change.

---

### Initialization 

I want to be able to initialize after cloning this on an new machine like the following:
```sh
    # for a personal machine.
    make init --personal

    # for a work machine.
    make init --work
```

A environment variable is set, that in the future will help identify current machine type `MACHINE_PROFILE`.

### Packages and Dependencies

We need to install dependencies first. So a `packages.yml` would be a good fit to this project, a single place to keep track of what needs to be installed without having to open sh files.

A yml file could be better, since different packages might have different ways of being installed (apt, curl, npm, pip, etc...). 
```yml
tools:
    - tree:
        script: ...
    - git:
        script: ...

applications:
    - docker:
        before: ... # could check if installed already.
        script: ...
    - awscli:
        script: ...
    - sdkman:
       script: ...
```

---

### Secrets

Secrets are not stored on tracked files, we have a global `{root}/{profile}/secrets` directory, where we can edit a `{root}/{profile}/secrets/.env.secrets` file.

We could have a `make check-secrets`, to validate that we have all required secrets filled, based on a comparisson with `{root}/{profile}/secrets/.env.secrets.template`. It leverages `MACHINE_PROFILE` variable to check for the correct directory to validate.
