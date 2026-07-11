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

step "nvm + Node 24"
[ -d "$HOME/.nvm" ] || curl -so- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.5/install.sh | bash >/dev/null
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
nvm list 2>/dev/null | grep -q "v24" || nvm install 24 >/dev/null

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

step "Obsidian + obsidian-cli, gh"
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
# Obsidian CLI: Yakitrak/obsidian-cli was renamed upstream to notesmd-cli — the old
# module path no longer resolves, so install via the new path. Built with go (from
# pkglist), binary lands in ~/go/bin as `notesmd-cli`.
[ -x "$HOME/go/bin/notesmd-cli" ] || go install github.com/Yakitrak/notesmd-cli@latest
# zsh completion → ~/.zsh_functions (already on fpath via config/shell/.zshrc).
if [ -x "$HOME/go/bin/notesmd-cli" ]; then
  mkdir -p "$HOME/.zsh_functions"
  "$HOME/go/bin/notesmd-cli" completion zsh > "$HOME/.zsh_functions/_notesmd-cli"
fi
step "1Password CLI (op)"
# Secrets workflow is 1Password-based: op run / op:// references (no local key
# material). Install from 1Password's official dnf repo (has a native rpm).
# direnv (from pkglist) pairs with `op run` for per-project env loading.
# NB: guard on the rpm, NOT `command -v op` — a stray user-local op (e.g.
# ~/.local/bin/op) would pass the check, but desktop-app integration only
# accepts the system binary (root:onepassword-cli, setgid). See LEARNINGS.md.
if ! rpm -q 1password-cli >/dev/null 2>&1; then
  sudo rpm --import https://downloads.1password.com/linux/keys/1password.asc
  sudo sh -c 'echo -e "[1password]\nname=1Password Stable Channel\nbaseurl=https://downloads.1password.com/linux/rpm/stable/\$basearch\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=\"https://downloads.1password.com/linux/keys/1password.asc\"" > /etc/yum.repos.d/1password.repo'
  sudo dnf install -q -y 1password-cli
fi
[ -e "$HOME/.local/bin/op" ] && echo "  WARNING: stray ~/.local/bin/op found — remove it (shadows the system op in some PATHs)"
echo "  Enable app integration: 1Password app → Settings → Developer → 'Integrate with 1Password CLI'"

step "Obsidian vault backup (rclone crypt → Google Drive)"
# Encrypted daily backup of ~/Documents/obsidian. Crypt keys + the full restore
# guide live in the 1Password item "obsidian-vault-backup" (Private vault).
# On a NEW machine: restore the vault first (guide in that item), then enable
# the timer. rclone comes from pkglist (Fedora repos).
command -v rclone >/dev/null || sudo dnf install -q -y rclone
install -D "$SCRIPT_DIR/../../config/backup/vault-backup.sh" "$HOME/.local/bin/vault-backup.sh"
mkdir -p "$HOME/.config/systemd/user"
cp "$SCRIPT_DIR/../../config/systemd/vault-backup.service" \
   "$SCRIPT_DIR/../../config/systemd/vault-backup.timer" "$HOME/.config/systemd/user/"
systemctl --user daemon-reload
echo "  Once per machine (interactive): follow the restore guide in the 1Password"
echo "  item 'obsidian-vault-backup' (rclone gdrive OAuth + gdrive-crypt remote),"
echo "  then: systemctl --user enable --now vault-backup.timer"

step "Claude Code config backup (rclone → Google Drive, UNENCRYPTED)"
# Daily backup of portable ~/.claude config (CLAUDE.md, settings.json, plugins/,
# skills/, commands/, agents/) via an ALLOWLIST — secrets and private history
# (.credentials.json, sessions/, projects/, history.jsonl) are never in scope.
# Reuses the same plain [gdrive] remote the vault OAuth sets up (above).
install -D "$SCRIPT_DIR/../../config/backup/claude-config-backup.sh" "$HOME/.local/bin/claude-config-backup.sh"
cp "$SCRIPT_DIR/../../config/systemd/claude-config-backup.service" \
   "$SCRIPT_DIR/../../config/systemd/claude-config-backup.timer" "$HOME/.config/systemd/user/"
systemctl --user daemon-reload
echo "  After the gdrive remote exists (see vault backup above):"
echo "  systemctl --user enable --now claude-config-backup.timer"

step "Antigravity setup"
bash "$SCRIPT_DIR/../config-agy.sh"
