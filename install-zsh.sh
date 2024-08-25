#!/usr/bin/env bash
#This is a script for quick shell config
sudo -v

mkdir -p $HOME/Downloads
cd $HOME/Downloads

command -v zsh &> /dev/null || sudo apt install zsh -y

[ ! -d "$HOME/.oh-my-zsh" ] && sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

[ $SHELL != "/usr/bin/zsh" ] && chsh -s $(which zsh)


[ ! -e "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ] && git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
[ ! -e "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ] && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting


if ! command -v starship &> /dev/null; then
    curl -sS https://starship.rs/install.sh | sh -y
    starship preset nerd-font-symbols -o $HOME/.config/starship.toml
else
    echo 'Starship is already installed'
fi

command -v zip &> /dev/null || sudo apt install zip -y

if ! fc-list | grep -qi 'Hack Nerd Font'; then
    wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/Hack.zip
    mkdir -p $HOME/.local/share/fonts
    unzip Hack.zip -d $HOME/.local/share/fonts
    rm Hack.zip
    fc-cache -fv
else
    echo 'Hack font already isntalled'
fi