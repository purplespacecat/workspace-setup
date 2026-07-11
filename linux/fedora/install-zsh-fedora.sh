#!/usr/bin/env bash
# Shell foundation: zsh, oh-my-zsh, plugins, starship, Nerd Font, configs.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR/../../config/shell"
ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}
step() { printf '\033[1;34m::\033[0m %s\n' "$1"; }

step "Base packages"
# curl is already provided by curl-minimal (@core); listing it forces a full-curl swap.
sudo dnf install -q -y zsh git unzip zip

step "oh-my-zsh + plugins"
[ -d "$HOME/.oh-my-zsh" ] || RUNZSH=no KEEPZSHRC=yes \
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" >/dev/null
[ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ] || \
  git clone -q https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
[ -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ] || \
  git clone -q https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
step "Default shell"
ZSH_PATH="$(which zsh)"
if [ "$(getent passwd "$USER" | cut -d: -f7)" = "$ZSH_PATH" ]; then
  echo "  Login shell already zsh"
elif chsh -s "$ZSH_PATH"; then
  echo "  Login shell set to zsh — log out and back in (or run 'exec zsh') for it to take effect"
else
  echo "  WARNING: chsh failed — set your shell manually with: chsh -s $ZSH_PATH"
fi

step "starship"
command -v starship >/dev/null || curl -sS https://starship.rs/install.sh | sh -s -- -y >/dev/null

step "Hack Nerd Font"
if ! fc-list | grep -qi 'Hack Nerd Font'; then
  curl -fsSL https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Hack.zip -o /tmp/Hack.zip
  mkdir -p "$HOME/.local/share/fonts"
  unzip -oq /tmp/Hack.zip -d "$HOME/.local/share/fonts"
  rm -f /tmp/Hack.zip
  fc-cache -f
fi

step "Config files"
mkdir -p "$HOME/.config"
cp "$CONFIG_DIR/starship.toml" "$HOME/.config/starship.toml"
cp "$CONFIG_DIR/.zshrc" "$HOME/.zshrc"
cp "$CONFIG_DIR/.tmux.conf" "$HOME/.tmux.conf"
