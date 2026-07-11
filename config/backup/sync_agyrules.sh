#!/usr/bin/env bash
set -euo pipefail

# Ensure rclone is available
if ! command -v rclone >/dev/null 2>&1; then
    echo "Error: rclone is not installed or not in PATH."
    exit 1
fi

# -L is required to follow the symlink created in the setup script
rclone copy -L "$HOME/.agyrules" gdrive:backups/
