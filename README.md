## workspace-setup
*This repo contains configuration files and automation scripts to quickly setup a working environment on new systems*

## Repository Structure
```
.
├── ansible/           # Ansible playbooks for automated setup
├── config/           # Configuration files
├── pkglists/        # Package lists for different distributions
└── scripts/         # Shell scripts for different operating systems
```

## What's included?
1. **Automation**:
   - `ansible/setup.yml`: Ansible playbook for automated environment setup on Linux systems
   - `scripts/install-zsh-arch.sh`: Shell script for Arch Linux setup
   - `scripts/install-zsh-ubuntu.sh`: Shell script for Ubuntu setup
   - `scripts/restore-windows-apps.ps1`: PowerShell script for Windows setup
   - `scripts/backup-system.sh`: Universal backup script for Linux systems
   - `scripts/restore-system.sh`: Universal restore script for Linux systems

2. **Configuration files**:
   - `config/.zshrc`: Zsh configuration with aliases and plugins
   - `config/starship.toml`: Starship prompt customization
   - `config/shell-tools.sh`: Additional shell tools configuration

3. **Package Lists**:
   - `pkglists/arch.txt`: Packages for Arch Linux
   - `pkglists/ubuntu.txt`: Essential packages for Ubuntu

## Usage
1. Clone this repository
2. Choose your preferred setup method:
   - For automated setup: `ansible-playbook ansible/setup.yml`
   - For manual setup: Run appropriate script from `scripts/` directory
3. Customize configuration files in `config/` as needed

## Backup and Restore
The repository now includes comprehensive backup and restore functionality for both Ubuntu and Arch Linux systems.

### Creating a Backup
```bash
# Make the script executable
chmod +x scripts/backup-system.sh

# Run the backup script
./scripts/backup-system.sh
```

The backup script will:
- Detect your Linux distribution (Ubuntu or Arch)
- Back up all installed packages (including AUR packages for Arch)
- Save system configurations and dotfiles
- Back up systemd services
- Store crontab entries
- Back up Flatpak and Snap packages if installed
- Create a dated tar archive in your home directory

### Restoring from Backup
```bash
# Make the script executable
chmod +x scripts/restore-system.sh

# Restore from a backup archive
./scripts/restore-system.sh path/to/backup.tar.gz
```

The restore script will:
- Automatically detect your distribution
- Restore all packages from the backup
- Restore your personal configurations
- Reinstall Flatpak and Snap packages
- Restore system services and crontab entries
