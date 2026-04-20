#!/usr/bin/env bash
# install.sh — bootstrap terminal setup on a fresh macOS or Linux machine
# Tools: oh-my-zsh, zoxide, eza, bat, fzf, fzf-tab, fd, nvm
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
  brew install git zsh zoxide eza bat fzf fd
}

# ── Linux (Debian/Ubuntu) ──────────────────────────────────────────────────────

install_linux() {
  log "Updating apt and installing base packages..."
  sudo apt-get update -y
  sudo apt-get install -y git zsh curl wget build-essential unzip

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

# ── nvm ────────────────────────────────────────────────────────────────────────

if [ ! -d "$HOME/.nvm" ]; then
  log "Installing nvm..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
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
