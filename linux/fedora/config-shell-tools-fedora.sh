#!/usr/bin/env bash
# Dev tools and applications.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
step() { printf '\033[1;34m::\033[0m %s\n' "$1"; }

step "System update + packages"
sudo dnf upgrade -q -y
sudo dnf install -q -y @development-tools
if [ -f "$SCRIPT_DIR/pkglist.txt" ]; then
  mapfile -t pkgs < <(grep -vE '^\s*#|^\s*$' "$SCRIPT_DIR/pkglist.txt")
  sudo dnf install -q -y --skip-unavailable "${pkgs[@]}"
fi

step "Neovim + LazyVim"
if ! command -v nvim >/dev/null; then
  curl -sL -o /tmp/nvim.tar.gz https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
  sudo rm -rf /opt/nvim-linux-x86_64
  sudo tar -C /opt -xzf /tmp/nvim.tar.gz
  rm -f /tmp/nvim.tar.gz
fi
[ -d "$HOME/.config/nvim" ] || { git clone -q https://github.com/LazyVim/starter ~/.config/nvim; rm -rf ~/.config/nvim/.git; }
[ -d "$HOME/.config/nvim/pack/github/start/copilot.vim" ] || \
  git clone -q https://github.com/github/copilot.vim.git ~/.config/nvim/pack/github/start/copilot.vim

step "tmux plugin manager"
[ -d "$HOME/.tmux/plugins/tpm" ] || git clone -q https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

step "nvm + Node 22"
[ -d "$HOME/.nvm" ] || curl -so- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | bash >/dev/null
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
nvm list 2>/dev/null | grep -q "v22" || nvm install 22 >/dev/null

step "fzf"
[ -d "$HOME/.fzf" ] || { git clone -q --depth 1 https://github.com/junegunn/fzf.git ~/.fzf; ~/.fzf/install --all --no-bash --no-fish >/dev/null; }

step "lazygit + yazi"
if ! command -v lazygit >/dev/null; then
  LG_VER=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
  curl -sLo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LG_VER}_Linux_x86_64.tar.gz"
  tar -C /tmp -xf /tmp/lazygit.tar.gz lazygit
  sudo install /tmp/lazygit /usr/local/bin
  rm -f /tmp/lazygit /tmp/lazygit.tar.gz
fi
if ! command -v yazi >/dev/null; then
  curl -sLo /tmp/yazi.zip "https://github.com/sxyazi/yazi/releases/latest/download/yazi-x86_64-unknown-linux-gnu.zip"
  unzip -oq /tmp/yazi.zip -d /tmp
  sudo install /tmp/yazi-x86_64-unknown-linux-gnu/yazi /usr/local/bin/
  rm -rf /tmp/yazi.zip /tmp/yazi-x86_64-unknown-linux-gnu
fi

step "Obsidian + obsidian-cli, gh, Bitwarden CLI"
# gh installed via pkglist (dnf). Obsidian has no native rpm — use Flatpak
# (preinstalled on Fedora Workstation/KDE).
if command -v flatpak >/dev/null; then
  if ! flatpak list 2>/dev/null | grep -qi obsidian; then
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    flatpak install -y flathub md.obsidian.Obsidian
  fi
else
  echo "  flatpak not found — skipping Obsidian (install flatpak to enable)"
fi
# Obsidian CLI (Yakitrak) — built with go (installed via pkglist), lands in ~/go/bin
[ -x "$HOME/go/bin/obsidian-cli" ] || go install github.com/Yakitrak/obsidian-cli@latest
# Bitwarden CLI — no maintained native rpm, install via npm (Node already set up)
command -v bw >/dev/null || npm install -g @bitwarden/cli >/dev/null
