#!/bin/bash

# Update package lists
sudo apt update

# Install packages from pkglist.txt
while read package; do
    sudo apt install -y "$package"
done < pkglist.txt

# Install LazyVim
git clone https://github.com/LazyVim/starter ~/.config/nvim || true

# Install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | bash || true

# Install GitHub Copilot for Neovim
git clone https://github.com/github/copilot.vim.git \
  ~/.config/nvim/pack/github/start/copilot.vim || true

# Source nvm and install Node.js
. "$HOME/.nvm/nvm.sh" || true
nvm install 22 || true

# Make the script executable after creating it
chmod +x "$0"