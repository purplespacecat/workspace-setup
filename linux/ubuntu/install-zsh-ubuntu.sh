#!/usr/bin/env bash
#This is a script for quick shell config on Ubuntu
#sudo -v

#Install zsh
command -v zsh &>/dev/null || sudo apt install zsh -y

#Install oh-my-zsh (RUNZSH=no: the installer otherwise execs into zsh and
#halts this script; KEEPZSHRC=yes: don't clobber .zshrc — we copy our own below)
[ ! -d "$HOME/.oh-my-zsh" ] && RUNZSH=no KEEPZSHRC=yes sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

#Set zsh as a default
[ "$SHELL" != "/usr/bin/zsh" ] && chsh -s "$(which zsh)"

#Install necessary plugins
[ ! -e "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ] && git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
[ ! -e "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ] && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

#Check if starship is installed
if ! command -v starship &>/dev/null; then
  curl -sS https://starship.rs/install.sh | sh -s -- -y
else
  echo 'Starship is already installed'
fi
#Check if zip is installed
command -v zip &>/dev/null || sudo apt install zip -y

#Install Hack Nerd Font
if ! fc-list | grep -qi 'Hack Nerd Font'; then
  wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Hack.zip -O /tmp/Hack.zip
  mkdir -p $HOME/.local/share/fonts
  unzip /tmp/Hack.zip -d $HOME/.local/share/fonts
  rm /tmp/Hack.zip
  fc-cache -fv
else
  echo 'Hack font already installed'
fi

#Copy config files
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR/../../config/shell"
mkdir -p $HOME/.config
cp "$CONFIG_DIR/starship.toml" $HOME/.config/starship.toml
cp "$CONFIG_DIR/.zshrc" $HOME/.zshrc

