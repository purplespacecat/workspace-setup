#!/usr/bin/env bash
# This is a script for quick shell config on Arch Linux

sudo -v

# Install necessary packages silently
sudo pacman -Sy --needed --noconfirm zsh git unzip zip wget base-devel

# Install yay if not installed
if ! command -v yay &> /dev/null; then
    echo "Installing yay..."
    git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
    cd /tmp/yay-bin && makepkg -si --noconfirm
    cd - && rm -rf /tmp/yay-bin
fi

# Install Starship without prompts
if ! command -v starship &> /dev/null; then
    echo "Installing Starship..."
    yay -S --needed --noconfirm --removemake --mflags "--nocheck" starship
    mkdir -p $HOME/.config
    starship preset nerd-font-symbols -o $HOME/.config/starship.toml
else
    echo "Starship is already installed"
fi

# Install Oh My Zsh
[ ! -d "$HOME/.oh-my-zsh" ] && sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Set Zsh as default shell
if [ "$SHELL" != "/usr/bin/zsh" ]; then
    chsh -s "$(which zsh)"
fi

# Install Zsh plugins
ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}
[ ! -e "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ] && git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
[ ! -e "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ] && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

# Install Hack Nerd Font
if ! fc-list | grep -qi 'Hack Nerd Font'; then
    echo "Installing Hack Nerd Font..."
    wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/Hack.zip -O /tmp/Hack.zip
    mkdir -p $HOME/.local/share/fonts
    unzip /tmp/Hack.zip -d $HOME/.local/share/fonts
    rm /tmp/Hack.zip
    fc-cache -fv
else
    echo "Hack Nerd Font is already installed"
fi

# Copy config files
mkdir -p $HOME/.config
cp ../config/starship.toml $HOME/.config/starship.toml
cp ../config/.zshrc $HOME/.zshrc

echo "Shell setup complete. Restart your terminal or run 'zsh' to apply changes."
