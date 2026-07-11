#!/usr/bin/env bash
# Antigravity tooling and backup setup
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR/../config"

# Ensure ~/.local/bin exists
mkdir -p "$HOME/.local/bin"

# Symlink .agyrules
ln -sf "$CONFIG_DIR/agy/.agyrules" "$HOME/.agyrules"

# Symlink sync script
ln -sf "$CONFIG_DIR/backup/sync_agyrules.sh" "$HOME/.local/bin/sync_agyrules.sh"
chmod +x "$HOME/.local/bin/sync_agyrules.sh"

# Setup systemd timer
mkdir -p "$HOME/.config/systemd/user"
cp "$CONFIG_DIR/systemd/agy-backup.service" "$CONFIG_DIR/systemd/agy-backup.timer" "$HOME/.config/systemd/user/"
systemctl --user daemon-reload

echo "  Antigravity setup complete."
echo "  Note: The backup requires the 'gdrive:' rclone remote to be configured."
echo "  Once rclone is authenticated, enable the backup timer with:"
echo "  systemctl --user enable --now agy-backup.timer"
