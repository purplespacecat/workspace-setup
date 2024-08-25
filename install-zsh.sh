#!/usr/bin/env bash
#This is a script for quick shell config
cd ~/Downloads
sudo apt install zsh
sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
chsh -s $(which zsh)
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
curl -sS https://starship.rs/install.sh | sh
starship preset nerd-font-symbols -o ~/.config/starship.toml
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/Hack.zip && unzip Hack.zip -d ~/.local/share/fonts
rm Hack.zip