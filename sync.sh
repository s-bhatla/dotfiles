#!/usr/bin/env bash
# sync.sh — copy live config from this machine into the repo, commit, push.
# Usage: dotsync ["commit message"]
set -euo pipefail

# ~/.local/bin/dotsync is a symlink to this file, so resolve the real repo dir
REPO="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

# Copy $1 to $2 if it exists and differs. Same-file symlinks compare equal.
grab() { [ -e "$1" ] && ! cmp -s "$1" "$2" && cp "$1" "$2" || true; }

if [ "$(uname -s)" = "Darwin" ]; then
  VSCODE_USER="$HOME/Library/Application Support/Code/User"
else
  VSCODE_USER="$HOME/.config/Code/User"
fi

grab "$HOME/.zshrc"                 "$REPO/.zshrc"
grab "$HOME/.claude/CLAUDE.md"      "$REPO/llm/CLAUDE.md"
grab "$VSCODE_USER/settings.json"   "$REPO/vscode/settings.json"

command -v code &>/dev/null && code --list-extensions > "$REPO/vscode/extensions.txt"

# Local skills: pull edits back from wherever the agent reads them
for dir in "$REPO"/llm/skills/*/; do
  live="$HOME/.claude/skills/$(basename "$dir")"
  [ -d "$live" ] && rsync -a --delete "$live/" "$dir"
done

# Public skills: rebuild skills.txt from the skills CLI lock file
LOCK="$HOME/.agents/.skill-lock.json"
if [ -f "$LOCK" ] && command -v jq &>/dev/null; then
  {
    echo "# Skills installed with the skills CLI (npx skills add). Format: <source> <skill>..."
    jq -r '.skills | to_entries | group_by(.value.source)[]
           | "\(.[0].value.source) \(map(.key) | join(" "))"' "$LOCK"
  } > "$REPO/llm/skills.txt"
fi

cd "$REPO"
git add -A
if git diff --cached --quiet; then
  echo "[dotfiles] Nothing changed."
  exit 0
fi
git diff --cached --stat
git commit -qm "${1:-Sync dotfiles}"
git push -q
echo "[dotfiles] Pushed."
