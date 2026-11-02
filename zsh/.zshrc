export ZSH="$HOME/.oh-my-zsh"

# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="rixius"

# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

# Asdf completions (must be on fpath before oh-my-zsh runs compinit)
#  $ mkdir -p "${ASDF_DATA_DIR:-$HOME/.asdf}/completions"
#  $ asdf completion zsh > "${ASDF_DATA_DIR:-$HOME/.asdf}/completions/_asdf"
fpath=(${ASDF_DATA_DIR:-$HOME/.asdf}/completions $fpath)

source $ZSH/oh-my-zsh.sh

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

export PATH="$PATH:$HOME/.local/bin"

# Golang
if [[ -d /usr/local/go/bin ]]; then
	export PATH="$PATH:/usr/local/go/bin"
fi
if command -v go >/dev/null 2>&1; then
	export PATH="$PATH:$(go env GOPATH)/bin"
fi

# Asdf
export PATH="$PATH:${ASDF_DATA_DIR:-$HOME/.asdf}/shims"

# Personal layer (only on machines where the personal submodule is installed)
[[ -f "$HOME/.config/personal/index" ]] && source "$HOME/.config/personal/index"

# added by UV installer
[[ -s "$HOME/.local/bin/env" ]] && . "$HOME/.local/bin/env"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# opencode
[[ -d "$HOME/.opencode/bin" ]] && export PATH="$HOME/.opencode/bin:$PATH"

# Starship
if command -v starship >/dev/null 2>&1; then
	eval "$(starship init zsh)"
fi

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"
[[ -f "$HOME/.asdf/plugins/java/set-java-home.zsh" ]] && . "$HOME/.asdf/plugins/java/set-java-home.zsh"
