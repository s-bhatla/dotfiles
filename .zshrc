##### OH MY ZSH CORE #####
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"

# Keep plugins minimal to avoid keybinding conflicts
plugins=(git eza)

source $ZSH/oh-my-zsh.sh


##### PATH / SDKs #####

# pipx
export PATH="$PATH:$HOME/.local/bin"


##### NVM #####
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"


##### FZF (MUST BE AFTER OH MY ZSH) #####
[ -f "$HOME/.fzf.zsh" ] && source "$HOME/.fzf.zsh"

# fzf-tab (completion UI)
source "$HOME/.fzf-tab/fzf-tab.plugin.zsh"


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


##### ALIASES #####

# git add + commit + push
alias gpush='f() { git add . && git commit -m "$1" && git push; }; f'
alias c='clear'

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

# Create branch, commit all changes, and push to origin
gbranch() {
  git checkout -b "$1"
  git add .
  git commit -m "$2"
  git push -u origin "$1"
}
