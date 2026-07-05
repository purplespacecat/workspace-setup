## Set up neovim
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
sudo rm -rf /opt/nvim-linux-x86_64
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
export PATH="$PATH:/opt/nvim-linux-x86_64/bin"

## Set up lazyvim
mv ~/.config/nvim{,.bak}
mv ~/.local/share/nvim{,.bak}
mv ~/.local/state/nvim{,.bak}
mv ~/.cache/nvim{,.bak}
# Clone starter 
git clone https://github.com/LazyVim/starter ~/.config/nvim

## Set up clipboard
sudo apt update
sudo apt install xclip

## Then make Neovim use system clipboard by adding to ~/.config/nvim/init.lua (or init.vim):
vim.opt.clipboard = "unnamedplus"

## Add to ~/.tmux.conf
set -g set-clipboard on

## Set up tmux persistance
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

Edit ~/.tmux.conf, add plugins
# List of plugins
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'tmux-plugins/tmux-resurrect'

# Initialize TMUX plugin manager (keep this line at the very bottom of tmux.conf)
run '~/.tmux/plugins/tpm/tpm'

set -g @plugin 'tmux-plugins/tmux-continuum'
set -g @continuum-restore 'on'

## Obsidian vault: encrypted backup & restore
# Daily encrypted backup (rclone crypt → Google Drive) is installed by
# linux/fedora/config-shell-tools-fedora.sh (script: config/backup/vault-backup.sh,
# units: config/systemd/vault-backup.{service,timer}).
# RESTORE on a new machine: open the 1Password item "obsidian-vault-backup" —
# its notes contain the full step-by-step guide (keys are its password/salt fields).
# After restore: systemctl --user enable --now vault-backup.timer
