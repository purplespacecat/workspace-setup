## workspace-setup
*This repo contains some scripts and config files to quickly setup a working environment on new laptop/vm*

## What's included?
1. **Shell setup scripts**:
   - `install-zsh-arch.sh`: Installs Zsh, Oh My Zsh, Starship prompt, and necessary plugins on Arch Linux.
   - `install-zsh-ubuntu.sh`: Installs Zsh, Oh My Zsh, Starship prompt, and necessary plugins on Ubuntu.

2. **Configuration files**:
   - `.zshrc`: Predefined Zsh configuration file with aliases, plugins, and Starship integration.
   - `starship.toml`: Configuration file for the Starship prompt with custom symbols and styles.

3. **Package management**:
   - `pkglist.txt`: A list of packages to install on Arch Linux using `pacman`.

4. **Additional scripts**:
   - `config-shell-tools-arch.sh`: Installs additional shell tools and configurations, including LazyVim and Node.js via NVM.
   - `restore-windows-apps.ps1`: A PowerShell script to restore essential applications and configurations on Windows, including WSL setup, app installations via Winget and Chocolatey, and enabling system features.

## Usage
1. Clone this repository to your local machine.
2. Run the appropriate script for your operating system to set up your environment.
3. Customize the configuration files as needed.
