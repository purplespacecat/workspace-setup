#!/usr/bin/env bash
#This is a script for quick shell config
sudo -v

if [[ ! -d "$HOME/Downloads" ]]; then
    mkdir $HOME/Downloads
    cd $HOME/Downloads
else
    cd $HOME/Downloads
fi

if ! command -v zsh &> /dev/null; then
    sudo apt install zsh -y
else
    echo 'Zsh is already installed'
fi

if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    echo 'Oh-my-zsh is already installed'
fi

if echo $SHELL != "/usr/bin/zsh"; then
    chsh -s $(which zsh)
else
    echo 'Default shell is zsh'
fi

if [[ ! -e "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" && ! -e "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
else
    echo 'zsh-autosuggestions and zsh-syntax-highlighting are already installed'
fi

if ! command -v starship &> /dev/null; then
    curl -sS https://starship.rs/install.sh | sh -y
    starship preset nerd-font-symbols -o $HOME/.config/starship.toml
else
    echo 'Starship is already installed'
fi

if ! command -v zip &> /dev/null; then
    sudo apt install zip -y
else
    echo 'Zip is already installed'
fi

if ! fc-list | grep -qi 'Hack Nerd Font'; then
    wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/Hack.zip
    mkdir -p $HOME/.local/share/fonts
    unzip Hack.zip -d $HOME/.local/share/fonts
    rm Hack.zip
    fc-cache -fv
else
    echo 'Hack font already isntalled'
fi