# dotfiles

Portable terminal setup for macOS and Linux (Debian/Ubuntu). One script installs everything from scratch.

## What's included

| Tool | Purpose |
|---|---|
| [oh-my-zsh](https://ohmyz.sh) | Zsh framework with plugin ecosystem |
| [eza](https://github.com/eza-community/eza) | Modern `ls` — colours, icons, git status |
| [bat](https://github.com/sharkdp/bat) | Syntax-highlighted `cat` |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | Smart `cd` that learns your frecent dirs |
| [fzf](https://github.com/junegunn/fzf) | Fuzzy finder — used for history and completion |
| [fzf-tab](https://github.com/Aloxaf/fzf-tab) | Replaces zsh tab completion with fzf UI |
| [fd](https://github.com/sharkdp/fd) | Fast `find` replacement (used by `cdf`) |
| [nvm](https://github.com/nvm-sh/nvm) | Node version manager |

## Shell features

- `ls` → `eza` (with colour, git status column)
- `ll` / `la` / `lt` → long, all-files, tree views via eza
- `bat` → syntax-highlighted file viewer
- `z <partial>` → jump to a frecent directory with zoxide
- `Ctrl+R` → fzf history search
- `cdf` → interactive fuzzy `cd` using fd + fzf
- `gpush "message"` → `git add . && git commit -m && git push`
- `gbranch <name> "message"` → create branch, commit, push to origin

## Install on a fresh machine

```bash
git clone https://github.com/sidharthbhatla/dotfiles.git ~/dotfiles
cd ~/dotfiles
bash install.sh
```

Then open a new terminal.

> **Note:** If a `~/.zshrc` already exists it will be backed up to `~/.zshrc.bak` before being replaced.

## Platform notes

| | macOS | Linux (Debian/Ubuntu) |
|---|---|---|
| Package manager | Homebrew (auto-installed) | apt |
| `bat` binary | `bat` | `batcat` (aliased automatically) |
| `fd` binary | `fd` | `fdfind` (aliased automatically) |
| `eza` | Homebrew | Downloaded from GitHub releases |
| `zoxide` | Homebrew | Official install script |

## Repo structure

```
dotfiles/
├── .zshrc       # zsh config — copy this to ~/.zshrc
└── install.sh   # bootstrap script
```
