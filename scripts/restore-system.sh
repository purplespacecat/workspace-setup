#!/usr/bin/env bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 <backup-archive.tar.gz>"
    exit 1
fi

BACKUP_ARCHIVE=$1
RESTORE_DIR="/tmp/system-restore"

# Detect distribution
if [ -f /etc/arch-release ]; then
    DISTRO="arch"
elif [ -f /etc/lsb-release ]; then
    DISTRO="ubuntu"
else
    echo "Unsupported distribution"
    exit 1
fi

# Extract backup
rm -rf "$RESTORE_DIR"
mkdir -p "$RESTORE_DIR"
tar -xzf "$BACKUP_ARCHIVE" -C "$RESTORE_DIR"
BACKUP_DIR=$(find "$RESTORE_DIR" -maxdepth 1 -type d -name "*-*-*" | head -n1)

if [ ! -d "$BACKUP_DIR" ]; then
    echo "Invalid backup archive"
    exit 1
fi

# Restore packages
if [ "$DISTRO" = "arch" ]; then
    # Install yay if not present
    if ! command -v yay >/dev/null 2>&1; then
        git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
        (cd /tmp/yay-bin && makepkg -si --noconfirm)
        rm -rf /tmp/yay-bin
    fi
    
    if [ -f "$BACKUP_DIR/pacman-packages.txt" ]; then
        sudo pacman -S --needed - < "$BACKUP_DIR/pacman-packages.txt"
    fi
    if [ -f "$BACKUP_DIR/aur-packages.txt" ]; then
        yay -S --needed - < "$BACKUP_DIR/aur-packages.txt"
    fi
elif [ "$DISTRO" = "ubuntu" ]; then
    if [ -f "$BACKUP_DIR/ubuntu-packages.txt" ]; then
        sudo dpkg --set-selections < "$BACKUP_DIR/ubuntu-packages.txt"
        sudo apt-get update
        sudo apt-get dselect-upgrade -y
    fi
fi

# Restore configurations
CONFIGS=(
    ".config"
    ".local/share/applications"
    ".local/share/fonts"
    ".ssh"
    ".gnupg"
    ".oh-my-zsh"
    ".zshrc"
    ".gitconfig"
)

for config in "${CONFIGS[@]}"; do
    if [ -e "$BACKUP_DIR/$config" ]; then
        rsync -av "$BACKUP_DIR/$config" "$HOME/"
    fi
done

# Restore system services
if [ -d "$BACKUP_DIR/systemd-services" ]; then
    sudo cp -r "$BACKUP_DIR/systemd-services/"* /etc/systemd/system/
    sudo systemctl daemon-reload
fi

# Restore crontab
if [ -f "$BACKUP_DIR/crontab" ]; then
    crontab "$BACKUP_DIR/crontab"
fi

# Restore Flatpak applications
if [ -f "$BACKUP_DIR/flatpak-packages.txt" ]; then
    while read -r app; do
        flatpak install -y "$app"
    done < "$BACKUP_DIR/flatpak-packages.txt"
fi

# Restore Snap packages
if [ -f "$BACKUP_DIR/snap-packages.txt" ]; then
    while read -r line; do
        if [[ $line =~ ^([a-zA-Z0-9-]+)[[:space:]] ]]; then
            app="${BASH_REMATCH[1]}"
            [ "$app" != "core" ] && sudo snap install "$app"
        fi
    done < "$BACKUP_DIR/snap-packages.txt"
fi

# Cleanup
rm -rf "$RESTORE_DIR"

echo "System restore completed!"