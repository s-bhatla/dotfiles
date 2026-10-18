# dotfiles

Full developer machine bootstrap for macOS and Linux (Debian/Ubuntu). One script installs everything from scratch.

## What's included

### Terminal & shell

| Tool | Purpose |
|---|---|
| [oh-my-zsh](https://ohmyz.sh) | Zsh framework with plugin ecosystem |
| [eza](https://github.com/eza-community/eza) | Modern `ls` — colours, icons, git status |
| [bat](https://github.com/sharkdp/bat) | Syntax-highlighted `cat` |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | Smart `cd` that learns your frecent dirs |
| [fzf](https://github.com/junegunn/fzf) | Fuzzy finder — history search and tab completion |
| [fzf-tab](https://github.com/Aloxaf/fzf-tab) | Replaces zsh tab completion with fzf UI |
| [fd](https://github.com/sharkdp/fd) | Fast `find` replacement |
| [ripgrep](https://github.com/BurntSushi/ripgrep) | Fast `grep` replacement |
| [tmux](https://github.com/tmux/tmux) | Terminal multiplexer — persistent sessions, pane splitting |
| [jq](https://jqlang.github.io/jq/) | JSON processor for the command line |
| [JetBrainsMono Nerd Font](https://www.nerdfonts.com/) | Font with icons for eza and terminal tools |

### Dev tools

| Tool | Purpose |
|---|---|
| [nvm](https://github.com/nvm-sh/nvm) | Node version manager (latest version, lazy-loaded) |
| [Python 3](https://www.python.org/) | System Python (latest available) |
| [uv](https://github.com/astral-sh/uv) | Fast Python package and project manager |
| [Go](https://go.dev/) | Go toolchain (latest stable) |
| [Rust](https://www.rust-lang.org/) | Rust toolchain via rustup |
| [gh](https://cli.github.com/) | GitHub CLI — PRs, issues, auth from the terminal |
| [git-delta](https://github.com/dandavison/delta) | Syntax-highlighted git diffs (set as default pager) |
| [direnv](https://direnv.net/) | Per-directory environment variables via `.envrc` |

### Apps (macOS only via Homebrew Cask)

| App | Purpose |
|---|---|
| [VS Code](https://code.visualstudio.com/) | Editor with `code` CLI |
| [OrbStack](https://orbstack.dev/) | Fast, lightweight Docker + Linux VMs |

> **Ghostty:** Install manually from [ghostty.org/download](https://ghostty.org/download) — not scripted on either platform.

## Shell features

- `ls` → `eza` (with colour, git status column)
- `ll` / `la` / `lt` → long, all-files, tree views via eza
- `bat` → syntax-highlighted file viewer
- `z <partial>` → jump to a frecent directory with zoxide
- `Ctrl+R` → fzf history search
- `cdf` → interactive fuzzy `cd` using fd + fzf
- `mkcd <dir>` → create directory and cd into it
- `..` / `...` / `....` → go up 1 / 2 / 3 directories
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
| Docker | OrbStack (Cask) | docker-ce via get.docker.com |
| VS Code | Homebrew Cask | Microsoft apt repo |
| `gh` | Homebrew | GitHub apt repo |
| Go | Homebrew | Official tarball from go.dev |
| `bat` binary | `bat` | `batcat` (aliased automatically) |
| `fd` binary | `fd` | `fdfind` (aliased automatically) |
| `eza` | Homebrew | Downloaded from GitHub releases |
| `zoxide` | Homebrew | Official install script |
| Nerd Font | Homebrew Cask | Downloaded from GitHub releases |

## VS Code setup

| File | Installed to |
|---|---|
| `vscode/settings.json` | symlink at `~/Library/Application Support/Code/User/settings.json` (macOS) or `~/.config/Code/User/settings.json` (Linux) |
| `vscode/extensions.txt` | installed with `code --install-extension` |

Edits in VS Code change the repo file. To update the extension list, run `code --list-extensions > vscode/extensions.txt`.

## LLM agent setup

`install.sh` puts all LLM files in `~/.agents`, then links each agent it finds to them.

| File | Source | Installed to |
|---|---|---|
| `CLAUDE.md` | `llm/CLAUDE.md` (copy) | `~/.agents/CLAUDE.md` |
| Public skills | `llm/skills.txt`, installed with `npx skills` | `~/.agents/skills/<name>` |
| Local skills | `llm/skills/<name>` (symlink) | `~/.agents/skills/<name>` |

| Agent found | Links |
|---|---|
| Claude Code | `~/.claude/CLAUDE.md` and `~/.claude/skills/<name>` |
| Codex | `~/.codex/AGENTS.md` (reads `~/.agents/skills` directly) |
| Gemini CLI | `~/.gemini/GEMINI.md` (reads `~/.agents/skills` directly) |
| Cursor | none (reads `~/.agents/skills` directly) |

The script moves a real file or folder that a link replaces to `~/.agents/backup`.
To add a public skill, add its source and name to `llm/skills.txt`.
To copy `CLAUDE.md` changes back into the repo, run `cp ~/.agents/CLAUDE.md llm/`.

## Repo structure

```
dotfiles/
├── .zshrc       # zsh config — copied to ~/.zshrc
├── llm/         # CLAUDE.md, skills.txt, local skills
└── install.sh   # bootstrap script
```
