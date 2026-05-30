#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Update and install packages
sudo dnf upgrade -y
sudo dnf install -y @development-tools

if [ -f "$SCRIPT_DIR/pkglist.txt" ]; then
  while read -r package; do
    [[ -z "$package" || "$package" =~ ^# ]] && continue
    sudo dnf install -y "$package"
  done < "$SCRIPT_DIR/pkglist.txt"
fi

# Neovim from official release (ensures latest)
if ! command -v nvim &>/dev/null; then
  echo "Installing Neovim..."
  cd /tmp
  curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
  sudo rm -rf /opt/nvim-linux-x86_64
  sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
  rm nvim-linux-x86_64.tar.gz
  if ! grep -q '/opt/nvim-linux-x86_64/bin' ~/.zshrc 2>/dev/null; then
    echo 'export PATH="$PATH:/opt/nvim-linux-x86_64/bin"' >> ~/.zshrc
  fi
  cd "$SCRIPT_DIR"
else
  echo "Neovim already installed"
fi

# LazyVim
if [ ! -d "$HOME/.config/nvim" ]; then
  echo "Installing LazyVim..."
  git clone https://github.com/LazyVim/starter ~/.config/nvim
  rm -rf ~/.config/nvim/.git
else
  echo "LazyVim already installed"
fi

# nvm
if [ ! -d "$HOME/.nvm" ]; then
  echo "Installing nvm..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | bash
else
  echo "nvm already installed"
fi

# Node.js 22 via nvm
if [ -d "$HOME/.nvm" ]; then
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
  if ! nvm list | grep -q "v22"; then
    echo "Installing Node.js 22..."
    nvm install 22
  else
    echo "Node.js 22 already installed"
  fi
fi

# Copilot.vim
if [ ! -d "$HOME/.config/nvim/pack/github/start/copilot.vim" ]; then
  echo "Installing Copilot.vim..."
  git clone https://github.com/github/copilot.vim.git \
    ~/.config/nvim/pack/github/start/copilot.vim
else
  echo "Copilot.vim already installed"
fi

# fzf (via git for shell integration — creates ~/.fzf.zsh sourced by .zshrc)
if [ ! -d "$HOME/.fzf" ]; then
  echo "Installing fzf..."
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
  ~/.fzf/install --all --no-bash --no-fish
else
  echo "fzf already installed"
fi

# lazygit
if ! command -v lazygit &>/dev/null; then
  echo "Installing lazygit..."
  LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
  cd /tmp
  curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
  tar xf lazygit.tar.gz lazygit
  sudo install lazygit /usr/local/bin
  rm lazygit lazygit.tar.gz
  cd "$SCRIPT_DIR"
else
  echo "lazygit already installed"
fi

# yazi
if ! command -v yazi &>/dev/null; then
  echo "Installing yazi..."
  cd /tmp
  curl -Lo yazi.zip "https://github.com/sxyazi/yazi/releases/latest/download/yazi-x86_64-unknown-linux-gnu.zip"
  unzip -q yazi.zip
  sudo install yazi-x86_64-unknown-linux-gnu/yazi /usr/local/bin/
  rm -rf yazi.zip yazi-x86_64-unknown-linux-gnu
  cd "$SCRIPT_DIR"
else
  echo "yazi already installed"
fi

# zoxide (available in Fedora repos)
if ! command -v zoxide &>/dev/null; then
  echo "Installing zoxide..."
  sudo dnf install -y zoxide
else
  echo "zoxide already installed"
fi

# bat (available in Fedora repos)
if ! command -v bat &>/dev/null; then
  echo "Installing bat..."
  sudo dnf install -y bat
else
  echo "bat already installed"
fi
