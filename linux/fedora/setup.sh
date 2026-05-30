#!/usr/bin/env bash
# Fedora workspace setup — single entry point.
# Runs the shell foundation, then dev tools and apps.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
step() { printf '\n\033[1;34m::\033[0m %s\n' "$1"; }

sudo -v

step "Shell foundation"
bash "$SCRIPT_DIR/install-zsh-fedora.sh"

step "Tools & applications"
bash "$SCRIPT_DIR/config-shell-tools-fedora.sh"

step "Setup complete."
echo "  Log out and back in (or run 'exec zsh') to start using zsh."
echo "  Run ./check-dotfiles.sh anytime to audit dotfiles and tools."
