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
