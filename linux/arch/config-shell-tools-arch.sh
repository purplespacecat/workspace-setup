#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Install packages (github-cli, obsidian, bitwarden-cli, go included via pkglist)
grep -vE '^\s*#|^\s*$' "$SCRIPT_DIR/pkglist.txt" | sudo pacman -S --needed --noconfirm -

git clone https://github.com/LazyVim/starter ~/.config/nvim || true
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.5/install.sh | bash || true

git clone https://github.com/github/copilot.vim.git \
  ~/.config/nvim/pack/github/start/copilot.vim || true

. "$HOME/.nvm/nvm.sh" || true
nvm install 24 || true

# Obsidian CLI — upstream renamed obsidian-cli → notesmd-cli (see LEARNINGS.md).
# Built with go, lands in ~/go/bin as `notesmd-cli`.
go install github.com/Yakitrak/notesmd-cli@latest || true

echo ":: Antigravity setup"
bash "$SCRIPT_DIR/../config-agy.sh"
