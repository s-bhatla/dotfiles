#!/usr/bin/env bash
# install.sh — bootstrap a developer machine on macOS or Linux
# Tools: zsh, oh-my-zsh, eza, bat, fzf, fzf-tab, fd, zoxide, ripgrep,
#        tmux, jq, direnv, gh, git-delta, go, python3, rust, uv, nvm,
#        docker (orbstack on mac / docker-ce on linux), vscode, nerd font
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log()  { echo -e "${GREEN}[dotfiles]${NC} $1"; }
warn() { echo -e "${YELLOW}[dotfiles]${NC} $1"; }
err()  { echo -e "${RED}[dotfiles]${NC} $1" >&2; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OS="$(uname -s)"

# ── macOS ──────────────────────────────────────────────────────────────────────

install_mac() {
  # Homebrew
  if ! command -v brew &>/dev/null; then
    log "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Add brew to PATH for the rest of this script
    if [ -f /opt/homebrew/bin/brew ]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    else
      eval "$(/usr/local/bin/brew shellenv)"
    fi
  fi

  log "Installing packages via Homebrew..."
  brew install git zsh zoxide eza bat fzf fd ripgrep tmux jq direnv gh git-delta go python3

  log "Installing apps..."
  brew install --cask visual-studio-code orbstack font-jetbrains-mono-nerd-font

  warn "Ghostty: not scripted — install manually from https://ghostty.org/download"
}

# ── Linux (Debian/Ubuntu) ──────────────────────────────────────────────────────

install_linux() {
  log "Updating apt and installing base packages..."
  sudo apt-get update -y
  sudo apt-get install -y git zsh curl wget build-essential unzip ripgrep \
    tmux jq direnv python3 python3-pip python3-venv python3-dev

  # bat (binary is called batcat on Ubuntu/Debian)
  if ! command -v bat &>/dev/null && ! command -v batcat &>/dev/null; then
    log "Installing bat..."
    sudo apt-get install -y bat || warn "bat not in apt — skipping (install manually)"
  fi

  # fd (binary is called fdfind on Ubuntu/Debian)
  if ! command -v fd &>/dev/null && ! command -v fdfind &>/dev/null; then
    log "Installing fd..."
    sudo apt-get install -y fd-find || warn "fd-find not in apt — skipping"
  fi

  # eza — download from GitHub releases
  if ! command -v eza &>/dev/null; then
    log "Installing eza..."
    EZA_TAG=$(curl -fsSL "https://api.github.com/repos/eza-community/eza/releases/latest" \
      | grep '"tag_name"' | sed 's/.*"tag_name": *"\([^"]*\)".*/\1/')
    [ -z "$EZA_TAG" ] && err "Failed to fetch eza release tag — check your internet connection."
    ARCH=$(uname -m)
    case "$ARCH" in
      x86_64)  EZA_ARCH="x86_64-unknown-linux-gnu" ;;
      aarch64) EZA_ARCH="aarch64-unknown-linux-gnu" ;;
      *)        err "Unsupported architecture: $ARCH" ;;
    esac
    curl -fsSLo /tmp/eza.tar.gz \
      "https://github.com/eza-community/eza/releases/download/${EZA_TAG}/eza_${EZA_ARCH}.tar.gz"
    tar -xzf /tmp/eza.tar.gz -C /tmp eza
    sudo mv /tmp/eza /usr/local/bin/eza
    rm -f /tmp/eza.tar.gz
  fi

  # zoxide — official install script
  if ! command -v zoxide &>/dev/null; then
    log "Installing zoxide..."
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
    export PATH="$HOME/.local/bin:$PATH"
  fi

  # fzf — git clone method (works on any distro)
  if ! command -v fzf &>/dev/null; then
    log "Installing fzf..."
    git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
    "$HOME/.fzf/install" --all --no-bash --no-fish
  fi

  # Docker CE — official convenience script
  if ! command -v docker &>/dev/null; then
    log "Installing Docker..."
    curl -fsSL https://get.docker.com | sh
    sudo usermod -aG docker "$USER"
    warn "Docker: log out and back in for group membership to take effect."
  fi

  # VS Code — Microsoft apt repo
  if ! command -v code &>/dev/null; then
    log "Installing VS Code..."
    curl -fsSL "https://packages.microsoft.com/keys/microsoft.asc" \
      | gpg --dearmor > /tmp/microsoft.gpg
    sudo install -o root -g root -m 644 /tmp/microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
    rm /tmp/microsoft.gpg
    echo "deb [arch=amd64,arm64,armhf] https://packages.microsoft.com/repos/code stable main" \
      | sudo tee /etc/apt/sources.list.d/vscode.list
    sudo apt-get update
    sudo apt-get install -y code
  fi

  # GitHub CLI — official apt repo
  if ! command -v gh &>/dev/null; then
    log "Installing GitHub CLI..."
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
      | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
      | sudo tee /etc/apt/sources.list.d/github-cli.list
    sudo apt-get update
    sudo apt-get install -y gh
  fi

  # git-delta
  if ! command -v delta &>/dev/null; then
    log "Installing git-delta..."
    sudo apt-get install -y git-delta 2>/dev/null \
      || warn "git-delta not in apt — install manually from https://github.com/dandavison/delta/releases"
  fi

  # Go — official tarball from golang.org
  if ! command -v go &>/dev/null; then
    log "Installing Go..."
    GO_VERSION=$(curl -fsSL "https://go.dev/VERSION?m=text" | head -1)
    [ -z "$GO_VERSION" ] && err "Failed to fetch Go version — check your internet connection."
    ARCH=$(uname -m)
    case "$ARCH" in
      x86_64)  GO_ARCH="amd64" ;;
      aarch64) GO_ARCH="arm64" ;;
      *)        err "Unsupported architecture for Go: $ARCH" ;;
    esac
    curl -fsSLo /tmp/go.tar.gz "https://go.dev/dl/${GO_VERSION}.linux-${GO_ARCH}.tar.gz"
    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf /tmp/go.tar.gz
    rm /tmp/go.tar.gz
  fi

  # JetBrainsMono Nerd Font
  if ! fc-list 2>/dev/null | grep -qi "JetBrainsMono"; then
    log "Installing JetBrainsMono Nerd Font..."
    FONT_VERSION=$(curl -fsSL "https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest" \
      | grep '"tag_name"' | sed 's/.*"tag_name": *"\([^"]*\)".*/\1/')
    if [ -z "$FONT_VERSION" ]; then
      warn "Failed to fetch Nerd Font version — skipping font install."
    else
      mkdir -p "$HOME/.local/share/fonts"
      curl -fsSLo /tmp/JetBrainsMono.tar.xz \
        "https://github.com/ryanoasis/nerd-fonts/releases/download/${FONT_VERSION}/JetBrainsMono.tar.xz"
      tar -xf /tmp/JetBrainsMono.tar.xz -C "$HOME/.local/share/fonts"
      fc-cache -f
      rm /tmp/JetBrainsMono.tar.xz
    fi
  fi

  warn "Ghostty: not available as a stable Linux package — install manually from https://ghostty.org/download"
}

# ── Dispatch ───────────────────────────────────────────────────────────────────

case "$OS" in
  Darwin) install_mac ;;
  Linux)  install_linux ;;
  *)      err "Unsupported OS: $OS" ;;
esac

# ── oh-my-zsh ──────────────────────────────────────────────────────────────────

if [ ! -d "$HOME/.oh-my-zsh" ]; then
  log "Installing oh-my-zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
    "" --unattended
fi

# ── fzf shell integration (macOS post-brew) ────────────────────────────────────

if [ "$OS" = "Darwin" ] && [ ! -f "$HOME/.fzf.zsh" ]; then
  log "Setting up fzf shell integration..."
  "$(brew --prefix)/opt/fzf/install" --all --no-bash --no-fish
fi

# ── fzf-tab ────────────────────────────────────────────────────────────────────

if [ ! -d "$HOME/.fzf-tab" ]; then
  log "Installing fzf-tab..."
  git clone --depth 1 https://github.com/Aloxaf/fzf-tab "$HOME/.fzf-tab"
fi

# ── Rust ───────────────────────────────────────────────────────────────────────

if [ ! -f "$HOME/.cargo/bin/rustc" ]; then
  log "Installing Rust..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
fi

# ── uv (Python package / project manager) ─────────────────────────────────────

if ! command -v uv &>/dev/null && [ ! -f "$HOME/.local/bin/uv" ]; then
  log "Installing uv..."
  curl -LsSf https://astral.sh/uv/install.sh | sh
fi

# ── git: configure delta as diff pager ────────────────────────────────────────

if command -v delta &>/dev/null; then
  git config --global core.pager delta
  git config --global interactive.diffFilter "delta --color-only"
  git config --global delta.navigate true
  git config --global delta.dark true
fi

# ── nvm ────────────────────────────────────────────────────────────────────────

if [ ! -d "$HOME/.nvm" ]; then
  log "Installing nvm..."
  NVM_VERSION=$(curl -fsSL "https://api.github.com/repos/nvm-sh/nvm/releases/latest" \
    | grep '"tag_name"' | sed 's/.*"tag_name": *"\([^"]*\)".*/\1/')
  [ -z "$NVM_VERSION" ] && err "Failed to fetch nvm release tag — check your internet connection."
  curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" | bash
fi

# ── .zshrc ─────────────────────────────────────────────────────────────────────

if [ -f "$HOME/.zshrc" ]; then
  warn "Backing up existing ~/.zshrc to ~/.zshrc.bak"
  cp "$HOME/.zshrc" "$HOME/.zshrc.bak"
fi

log "Installing .zshrc..."
cp "$SCRIPT_DIR/.zshrc" "$HOME/.zshrc"

# ── Set zsh as default shell ───────────────────────────────────────────────────

ZSH_PATH="$(command -v zsh)"
if [ "$SHELL" != "$ZSH_PATH" ]; then
  log "Changing default shell to zsh..."
  if grep -qF "$ZSH_PATH" /etc/shells; then
    chsh -s "$ZSH_PATH"
  else
    echo "$ZSH_PATH" | sudo tee -a /etc/shells
    chsh -s "$ZSH_PATH"
  fi
fi

log ""
log "Done! Open a new terminal to start using your setup."
log "  ls       → eza (colours + git status)"
log "  bat      → syntax-highlighted cat"
log "  z <dir>  → zoxide smart jump"
log "  Ctrl+R   → fzf history search"
log "  cdf      → fuzzy cd with fzf + fd"
