#!/usr/bin/env bash

# Detect distribution
if [ -f /etc/arch-release ]; then
    DISTRO="arch"
elif [ -f /etc/lsb-release ]; then
    DISTRO="ubuntu"
else
    echo "Unsupported distribution"
    exit 1
fi

# Create backup directory
BACKUP_DIR="$HOME/system-backup/$(date +%Y-%m-%d)"
mkdir -p "$BACKUP_DIR"

# Backup package lists
if [ "$DISTRO" = "arch" ]; then
    pacman -Qqe > "$BACKUP_DIR/pacman-packages.txt"
    pacman -Qqem > "$BACKUP_DIR/aur-packages.txt"
elif [ "$DISTRO" = "ubuntu" ]; then
    dpkg --get-selections > "$BACKUP_DIR/ubuntu-packages.txt"
    apt list --manual-installed > "$BACKUP_DIR/manual-packages.txt"
fi

# Backup important config directories
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
    if [ -e "$HOME/$config" ]; then
        rsync -av --relative "$HOME/$config" "$BACKUP_DIR/"
    fi
done

# Backup system services
sudo cp -r /etc/systemd/system/* "$BACKUP_DIR/systemd-services/"

# Backup crontabs
if [ -f /var/spool/cron/$USER ]; then
    cp /var/spool/cron/$USER "$BACKUP_DIR/crontab"
fi

# Create list of manually installed applications
if [ "$DISTRO" = "arch" ]; then
    yay -Qm > "$BACKUP_DIR/aur-packages-full.txt"
elif [ "$DISTRO" = "ubuntu" ]; then
    apt-mark showmanual > "$BACKUP_DIR/manual-packages-full.txt"
fi

# Backup flatpak and snap packages if they exist
if command -v flatpak >/dev/null 2>&1; then
    flatpak list --app --columns=application > "$BACKUP_DIR/flatpak-packages.txt"
fi

if command -v snap >/dev/null 2>&1; then
    snap list > "$BACKUP_DIR/snap-packages.txt"
fi

# Create tarball of the backup
tar -czf "$BACKUP_DIR.tar.gz" -C "$(dirname "$BACKUP_DIR")" "$(basename "$BACKUP_DIR")"

echo "Backup completed: $BACKUP_DIR.tar.gz"