##### HISTORY #####
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_IGNORE_DUPS HIST_IGNORE_SPACE HIST_VERIFY SHARE_HISTORY


##### OH MY ZSH CORE #####
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"

# Keep plugins minimal to avoid keybinding conflicts
plugins=(git eza)

source $ZSH/oh-my-zsh.sh


##### PATH / SDKs #####

# pipx / uv / zoxide (installed to ~/.local/bin)
export PATH="$PATH:$HOME/.local/bin"

# Go (Linux installs to /usr/local/go; macOS brew manages its own PATH)
[ -d "/usr/local/go/bin" ] && export PATH="$PATH:/usr/local/go/bin"

# Rust
[ -d "$HOME/.cargo/bin" ] && export PATH="$PATH:$HOME/.cargo/bin"


##### NVM (lazy-loaded for fast shell startup) #####
export NVM_DIR="$HOME/.nvm"

_load_nvm() {
  unset -f nvm node npm npx
  [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"
}
nvm()  { _load_nvm; nvm  "$@"; }
node() { _load_nvm; node "$@"; }
npm()  { _load_nvm; npm  "$@"; }
npx()  { _load_nvm; npx  "$@"; }


##### FZF (MUST BE AFTER OH MY ZSH) #####
[ -f "$HOME/.fzf.zsh" ] && source "$HOME/.fzf.zsh"

# fzf-tab (completion UI)
[ -f "$HOME/.fzf-tab/fzf-tab.plugin.zsh" ] && source "$HOME/.fzf-tab/fzf-tab.plugin.zsh"


##### FORCE FZF KEYBINDINGS #####

# Ctrl+R → fzf history
bindkey '^R' fzf-history-widget

# If vi-mode ever gets enabled, bind both maps safely
bindkey -M viins '^R' fzf-history-widget 2>/dev/null
bindkey -M vicmd '^R' fzf-history-widget 2>/dev/null


##### CUSTOM FUNCTIONS #####

# cd using fd + fzf
cdf() {
  local dir
  dir=$(fd --type d . ${1:-.} | fzf) && cd "$dir"
}

# make directory and cd into it
mkcd() { mkdir -p "$1" && cd "$1"; }


##### ALIASES #####

# git add + commit + push
alias gpush='f() { git add . && git commit -m "$1" && git push; }; f'
alias c='clear'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# On Linux, bat is installed as batcat
if command -v batcat &>/dev/null && ! command -v bat &>/dev/null; then
  alias bat='batcat'
fi

# On Linux, fd is installed as fdfind
if command -v fdfind &>/dev/null && ! command -v fd &>/dev/null; then
  alias fd='fdfind'
fi


##### OPTIONAL QUALITY OF LIFE #####

# Faster completion
zstyle ':completion:*' menu select

# Case-insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

eval "$(zoxide init zsh --cmd z)"

# direnv — per-project environment variables
command -v direnv &>/dev/null && eval "$(direnv hook zsh)"

# Create branch, commit all changes, and push to origin
gbranch() {
  git checkout -b "$1"
  git add .
  git commit -m "$2"
  git push -u origin "$1"
}
