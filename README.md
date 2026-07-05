# Workspace Setup

This repository contains scripts and configuration files to quickly set up a working environment on new laptops or virtual machines across different operating systems.

## Directory Structure

```
.
├── config/
│   └── shell/
│       ├── starship.toml    # Starship prompt configuration
│       └── .zshrc          # Zsh shell configuration
├── linux/
│   ├── arch/
│   │   ├── config-shell-tools-arch.sh   # Additional shell tools setup
│   │   ├── install-zsh-arch.sh          # Zsh installation for Arch
│   │   └── pkglist.txt                  # Arch Linux package list
│   └── ubuntu/
│       └── install-zsh-ubuntu.sh        # Zsh installation for Ubuntu
└── windows/
    └── restore-windows-apps.ps1         # Windows apps restoration script
```

## Features

### Linux Setup
#### Arch Linux
- Complete Zsh environment setup with Oh My Zsh and Starship prompt
- Additional development tools installation
- Package installation from predefined list
- Shell customization and configuration

#### Ubuntu
- Zsh environment setup with Oh My Zsh and Starship prompt
- Shell customization and configuration

### Windows Setup
- Automated application restoration via Winget and Chocolatey
- WSL setup and configuration
- System features enablement
- Development environment configuration

### Shell Configuration
- Custom Zsh configuration with useful aliases and plugins
- Starship prompt with custom styling and features

## Usage

1. Clone this repository:
   ```bash
   git clone <repository-url>
   cd workspace-setup
   ```

2. Choose the appropriate script for your operating system:

   ### For Arch Linux:
   ```bash
   cd linux/arch
   ./install-zsh-arch.sh
   ./config-shell-tools-arch.sh
   ```

   ### For Ubuntu:
   ```bash
   cd linux/ubuntu
   ./install-zsh-ubuntu.sh
   ```

   ### For Fedora:
   ```bash
   cd linux/fedora
   ./setup.sh                    # shell foundation + dev tools & apps

   # Optional — infra / Kubernetes tooling (kubectl, k9s, flux):
   ./install-infra-fedora.sh
   ```

   ### For Windows:
   ```powershell
   cd windows
   .\restore-windows-apps.ps1
   ```

3. Configuration files are located in the `config` directory:
   - Copy `config/shell/.zshrc` to your home directory
   - Copy `config/shell/starship.toml` to `~/.config/starship.toml`

## Customization

You can customize the configuration files according to your needs:
- Edit `config/shell/.zshrc` for shell preferences
- Modify `config/shell/starship.toml` for prompt customization
- Update `linux/arch/pkglist.txt` to change the package selection for Arch Linux
