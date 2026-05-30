#!/bin/bash

# Get script directory for relative path resolution
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Update package lists
sudo apt update

# Install packages from pkglist.txt
if [ -f "$SCRIPT_DIR/pkglist.txt" ]; then
    while read package; do
        # Skip empty lines and comments
        [[ -z "$package" || "$package" =~ ^# ]] && continue
        sudo apt install -y "$package"
    done < "$SCRIPT_DIR/pkglist.txt"
fi

# Install Neovim from official release
if ! command -v nvim &> /dev/null; then
    echo "Installing Neovim..."
    cd /tmp
    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
    sudo rm -rf /opt/nvim-linux-x86_64
    sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
    rm nvim-linux-x86_64.tar.gz

    # Add to PATH if not already present
    if ! grep -q '/opt/nvim-linux-x86_64/bin' ~/.zshrc 2>/dev/null; then
        echo 'export PATH="$PATH:/opt/nvim-linux-x86_64/bin"' >> ~/.zshrc
    fi
    if ! grep -q '/opt/nvim-linux-x86_64/bin' ~/.bashrc 2>/dev/null; then
        echo 'export PATH="$PATH:/opt/nvim-linux-x86_64/bin"' >> ~/.bashrc
    fi

    cd "$SCRIPT_DIR"
else
    echo "Neovim is already installed"
fi

# Install LazyVim
if [ ! -d "$HOME/.config/nvim" ]; then
    echo "Installing LazyVim..."
    git clone https://github.com/LazyVim/starter ~/.config/nvim
    rm -rf ~/.config/nvim/.git
else
    echo "LazyVim already installed"
fi

# Install nvm
if [ ! -d "$HOME/.nvm" ]; then
    echo "Installing nvm..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | bash
else
    echo "nvm is already installed"
fi

# Install GitHub Copilot for Neovim
if [ ! -d "$HOME/.config/nvim/pack/github/start/copilot.vim" ]; then
    echo "Installing Copilot.vim..."
    git clone https://github.com/github/copilot.vim.git \
      ~/.config/nvim/pack/github/start/copilot.vim
else
    echo "Copilot.vim already installed"
fi

# Source nvm and install Node.js
if [ -d "$HOME/.nvm" ]; then
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

    # Check if Node.js 22 is installed
    if ! nvm list | grep -q "v22"; then
        echo "Installing Node.js 22..."
        nvm install 22
    else
        echo "Node.js 22 is already installed"
    fi
fi

# Install fzf
if [ ! -d "$HOME/.fzf" ]; then
    echo "Installing fzf..."
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install
else
    echo "fzf is already installed"
fi

# Install lazygit
if ! command -v lazygit &> /dev/null; then
    echo "Installing lazygit..."
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    cd /tmp
    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    tar xf lazygit.tar.gz lazygit
    sudo install lazygit /usr/local/bin
    rm lazygit lazygit.tar.gz
    cd "$SCRIPT_DIR"
else
    echo "lazygit is already installed"
fi

# Install yazi
if ! command -v yazi &> /dev/null; then
    echo "Installing yazi..."
    cd /tmp
    curl -Lo yazi.zip "https://github.com/sxyazi/yazi/releases/latest/download/yazi-x86_64-unknown-linux-gnu.zip"
    unzip -q yazi.zip
    sudo install yazi-x86_64-unknown-linux-gnu/yazi /usr/local/bin/
    rm -rf yazi.zip yazi-x86_64-unknown-linux-gnu
    cd "$SCRIPT_DIR"
else
    echo "yazi is already installed"
fi

# Install zoxide
if ! command -v zoxide &> /dev/null; then
    echo "Installing zoxide..."
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
else
    echo "zoxide is already installed"
fi

# Install GitHub CLI (official apt repo)
if ! command -v gh &> /dev/null; then
    echo "Installing GitHub CLI..."
    sudo mkdir -p -m 755 /etc/apt/keyrings
    wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null
    sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    sudo apt update
    sudo apt install -y gh
else
    echo "gh is already installed"
fi

# Install Obsidian (.deb)
if ! command -v obsidian &> /dev/null; then
    echo "Installing Obsidian..."
    OBSIDIAN_VERSION=$(curl -s "https://api.github.com/repos/obsidianmd/obsidian-releases/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    curl -Lo /tmp/obsidian.deb "https://github.com/obsidianmd/obsidian-releases/releases/latest/download/obsidian_${OBSIDIAN_VERSION}_amd64.deb"
    sudo apt install -y /tmp/obsidian.deb
    rm -f /tmp/obsidian.deb
else
    echo "Obsidian is already installed"
fi

# Install Obsidian CLI (Yakitrak) via go; lands in ~/go/bin
if [ ! -x "$HOME/go/bin/obsidian-cli" ]; then
    echo "Installing Obsidian CLI..."
    go install github.com/Yakitrak/obsidian-cli@latest
else
    echo "Obsidian CLI is already installed"
fi

# Install Bitwarden CLI (no maintained native package; use npm)
if ! command -v bw &> /dev/null; then
    echo "Installing Bitwarden CLI..."
    npm install -g @bitwarden/cli
else
    echo "Bitwarden CLI is already installed"
fi