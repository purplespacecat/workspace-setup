# Workspace Setup

This repository contains scripts and configuration files to quickly set up a working environment on new laptops or virtual machines across different operating systems.

## Directory Structure

```text
.
├── config/
│   ├── backup/
│   │   └── vault-backup.sh              # Encrypted Obsidian vault backup (rclone crypt)
│   ├── shell/
│   │   ├── .tmux.conf                   # Tmux configuration (TPM plugins)
│   │   ├── .zshrc                       # Zsh shell configuration
│   │   └── starship.toml                # Starship prompt configuration
│   └── systemd/
│       ├── vault-backup.service         # User unit for the vault backup
│       └── vault-backup.timer           # Daily backup timer
├── linux/
│   ├── arch/
│   │   ├── config-shell-tools-arch.sh   # Additional shell tools setup
│   │   ├── install-zsh-arch.sh          # Zsh installation for Arch
│   │   └── pkglist.txt                  # Arch Linux package list (official repos only)
│   ├── fedora/
│   │   ├── setup.sh                     # Single entry point (runs the two below)
│   │   ├── install-zsh-fedora.sh        # Shell foundation (zsh, OMZ, starship, font)
│   │   ├── config-shell-tools-fedora.sh # Dev tools, apps, 1Password CLI, vault backup
│   │   ├── install-infra-fedora.sh      # OPTIONAL: kubectl, k9s, flux, helm, kustomize
│   │   ├── check-dotfiles.sh            # Audit dotfiles/tools, offer fixes
│   │   └── pkglist.txt                  # Fedora package list
│   └── ubuntu/
│       ├── install-zsh-ubuntu.sh        # Zsh installation for Ubuntu
│       ├── config-shell-tools-ubuntu.sh # Additional shell tools setup
│       ├── setup-tmux.sh                # Tmux + TPM setup
│       └── pkglist.txt                  # Ubuntu package list
├── windows/
│   └── restore-windows-apps.ps1         # Windows apps restoration script
├── ACTIONS.md                           # Manual one-off setup notes
└── LEARNINGS.md                         # Non-obvious gotchas — read before editing scripts
```

## Features

### Linux Setup

#### Arch Linux

- Complete Zsh environment setup with Oh My Zsh and Starship prompt
- Additional development tools installation
- Package installation from predefined list
- Shell customization and configuration

#### Fedora

- Single-entry-point setup (`setup.sh`): shell foundation plus dev tools and apps
- 1Password CLI (`op`) secrets workflow and direnv
- Encrypted Obsidian vault backup (rclone crypt → Google Drive, systemd timer)
- Optional opt-in infra tooling (kubectl, k9s, flux, helm, kustomize)
- Dotfile/tool health check with interactive fixes (`check-dotfiles.sh`)

#### Ubuntu

- Zsh environment setup with Oh My Zsh and Starship prompt
- Additional development tools installation (Neovim, LazyVim, nvm, lazygit, yazi, ...)
- Tmux with plugin manager
- Shell customization and configuration

### Windows Setup

- Automated application restoration via Winget and Chocolatey
- WSL setup and configuration
- System features enablement
- Development environment configuration

### Shell Configuration

- Custom Zsh configuration with useful aliases and plugins
- Starship prompt with custom styling and features
- Tmux configuration with session persistence (resurrect + continuum)

## Usage

1. Clone this repository:

   ```bash
   git clone <repository-url>
   cd workspace-setup
   ```

2. Choose the appropriate script for your operating system:

   ### For Arch Linux

   ```bash
   cd linux/arch
   ./install-zsh-arch.sh
   ./config-shell-tools-arch.sh
   ```

   ### For Fedora

   ```bash
   cd linux/fedora
   ./setup.sh                    # shell foundation + dev tools & apps

   # Optional — infra / Kubernetes tooling (kubectl, k9s, flux, helm, kustomize):
   ./install-infra-fedora.sh

   # Anytime — audit dotfiles and tools, with interactive fixes:
   ./check-dotfiles.sh
   ```

   ### For Ubuntu

   ```bash
   cd linux/ubuntu
   ./install-zsh-ubuntu.sh
   ./config-shell-tools-ubuntu.sh
   ./setup-tmux.sh
   ```

   ### For Windows

   ```powershell
   cd windows
   .\restore-windows-apps.ps1
   ```

3. Configuration files are located in the `config` directory:
   - Copy `config/shell/.zshrc` to your home directory
   - Copy `config/shell/starship.toml` to `~/.config/starship.toml`
   - Copy `config/shell/.tmux.conf` to your home directory

## Customization

You can customize the configuration files according to your needs:

- Edit `config/shell/.zshrc` for shell preferences
- Modify `config/shell/starship.toml` for prompt customization
- Update `linux/<distro>/pkglist.txt` to change the package selection
