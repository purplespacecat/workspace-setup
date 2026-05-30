#!/usr/bin/env bash

# Install base dependencies
sudo dnf install -y zsh git wget unzip zip

# Install oh-my-zsh
[ ! -d "$HOME/.oh-my-zsh" ] && sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Set zsh as default
[ "$SHELL" != "$(which zsh)" ] && chsh -s "$(which zsh)"

# Install zsh plugins
[ ! -e "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ] && \
  git clone https://github.com/zsh-users/zsh-autosuggestions \
    "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"

[ ! -e "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ] && \
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
    "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"

# Install starship
if ! command -v starship &>/dev/null; then
  curl -sS https://starship.rs/install.sh | sh -s -- -y
  starship preset nerd-font-symbols -o "$HOME/.config/starship.toml"
else
  echo 'Starship already installed'
fi

# Install Hack Nerd Font
if ! fc-list | grep -qi 'Hack Nerd Font'; then
  wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/Hack.zip
  mkdir -p "$HOME/.local/share/fonts"
  unzip Hack.zip -d "$HOME/.local/share/fonts"
  rm Hack.zip
  fc-cache -fv
else
  echo 'Hack Nerd Font already installed'
fi

# Copy shared config files
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR/../../config/shell"
mkdir -p "$HOME/.config"
cp "$CONFIG_DIR/starship.toml" "$HOME/.config/starship.toml"
cp "$CONFIG_DIR/.zshrc" "$HOME/.zshrc"
cp "$CONFIG_DIR/.tmux.conf" "$HOME/.tmux.conf"
