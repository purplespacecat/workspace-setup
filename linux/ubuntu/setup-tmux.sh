#\!/bin/bash

# Get script directory for relative path resolution
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR/../../config/shell"

# Install tmux if not already installed
if \! command -v tmux &> /dev/null; then
    echo "Installing tmux..."
    sudo apt update
    sudo apt install -y tmux
else
    echo "tmux is already installed"
fi

# Install TPM (Tmux Plugin Manager)
if [ \! -d "$HOME/.tmux/plugins/tpm" ]; then
    echo "Installing Tmux Plugin Manager..."
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
else
    echo "TPM is already installed"
fi

# Copy tmux configuration
if [ -f "$CONFIG_DIR/.tmux.conf" ]; then
    echo "Copying tmux configuration..."
    cp "$CONFIG_DIR/.tmux.conf" "$HOME/.tmux.conf"
    echo "tmux configuration installed"
else
    echo "Warning: .tmux.conf not found in config directory"
fi

echo ""
echo "Tmux setup complete\!"
echo "To install tmux plugins, start tmux and press: prefix + I (capital i)"
echo "Default prefix is Ctrl+b"
