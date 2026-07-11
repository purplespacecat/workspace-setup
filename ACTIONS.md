# Manual setup actions

One-off commands and snippets for steps that aren't (yet) automated by the
setup scripts. Kept as a reference / scratchpad.

## Set up neovim

```bash
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
sudo rm -rf /opt/nvim-linux-x86_64
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
export PATH="$PATH:/opt/nvim-linux-x86_64/bin"
```

## Set up LazyVim

```bash
# Back up any existing config first
mv ~/.config/nvim{,.bak}
mv ~/.local/share/nvim{,.bak}
mv ~/.local/state/nvim{,.bak}
mv ~/.cache/nvim{,.bak}

# Clone starter
git clone https://github.com/LazyVim/starter ~/.config/nvim
```

## Set up clipboard

```bash
sudo apt update
sudo apt install xclip
```

Then make Neovim use the system clipboard by adding to
`~/.config/nvim/init.lua`:

```lua
vim.opt.clipboard = "unnamedplus"
```

And add to `~/.tmux.conf`:

```tmux
set -g set-clipboard on
```

## Set up tmux persistence

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

Edit `~/.tmux.conf` and add the plugins:

```tmux
# List of plugins
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @plugin 'tmux-plugins/tmux-continuum'
set -g @continuum-restore 'on'

# Initialize TMUX plugin manager (keep this line at the very bottom of tmux.conf)
run '~/.tmux/plugins/tpm/tpm'
```

## Obsidian vault: encrypted backup & restore

Daily encrypted backup (rclone crypt → Google Drive) is installed by
`linux/fedora/config-shell-tools-fedora.sh` (script:
`config/backup/vault-backup.sh`, units:
`config/systemd/vault-backup.{service,timer}`).

RESTORE on a new machine: open the 1Password item `obsidian-vault-backup` —
its notes contain the full step-by-step guide (keys are its password/salt
fields). After restore:

```bash
systemctl --user enable --now vault-backup.timer
```
