#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Install packages (github-cli, obsidian, bitwarden-cli, go included via pkglist)
sudo pacman -S --needed --noconfirm - < "$SCRIPT_DIR/pkglist.txt"

git clone https://github.com/LazyVim/starter ~/.config/nvim || true
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | bash || true

git clone https://github.com/github/copilot.vim.git \
  ~/.config/nvim/pack/github/start/copilot.vim || true

. "$HOME/.nvm/nvm.sh" || true
nvm install 22 || true

# Obsidian CLI (Yakitrak) — built with go, lands in ~/go/bin
go install github.com/Yakitrak/obsidian-cli@latest || true
