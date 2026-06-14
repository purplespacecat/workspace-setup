# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This repository contains automated setup scripts and configuration files for quickly setting up development environments on new laptops or VMs across Linux (Arch, Ubuntu, Fedora) and Windows platforms.

> **Read [LEARNINGS.md](LEARNINGS.md) before modifying install logic** — it records non-obvious gotchas (upstream renames, broken pinned URLs, package quirks). Add an entry whenever a fix turns out to be non-obvious.

## Repository Structure

The repository is organized by operating system:

- `linux/arch/` - Arch Linux setup scripts and package list
- `linux/ubuntu/` - Ubuntu setup scripts
- `linux/fedora/` - Fedora setup scripts (`setup.sh` entry point → `install-zsh-fedora.sh`, `config-shell-tools-fedora.sh`) and `pkglist.txt`
- `windows/` - Windows PowerShell setup script
- `config/shell/` - Shared shell configuration files (.zshrc, starship.toml)

## Script Architecture

### Linux Scripts Pattern

All Linux setup scripts follow a consistent architecture:

1. **Dependency Checking**: Use `command -v` to check if tools are installed before attempting installation
2. **Idempotent Installations**: Check for existing installations (e.g., `[ ! -d "$HOME/.oh-my-zsh" ]`) to avoid redundant operations
3. **Configuration Path Resolution**: Use `SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"` to locate scripts, then reference shared config files via relative paths like `$SCRIPT_DIR/../../config/shell`
4. **Silent Installation**: Use appropriate flags (`--noconfirm` for pacman, `-y` for apt) to avoid interactive prompts

### Key Installation Flow

**Arch Linux** (`linux/arch/install-zsh-arch.sh`):
- Installs base tools via pacman (zsh, git, unzip, zip, wget, base-devel)
- Installs yay (AUR helper) if missing
- Installs Starship prompt via yay
- Installs Oh My Zsh framework
- Clones zsh plugins (autosuggestions, syntax-highlighting) to `~/.oh-my-zsh/custom/plugins/`
- Downloads and installs Hack Nerd Font v3.2.1 to `~/.local/share/fonts`
- Copies shared config files from `config/shell/` to home directory

**Ubuntu** (`linux/ubuntu/install-zsh-ubuntu.sh`):
- Similar flow but uses apt instead of pacman
- Uses curl for Starship installation instead of yay
- Uses wget for Oh My Zsh installation

**Arch Additional Tools** (`linux/arch/config-shell-tools-arch.sh`):
- Installs packages from `pkglist.txt` via pacman
- Clones LazyVim starter config to `~/.config/nvim`
- Installs nvm and Node.js 22
- Installs Copilot.vim to `~/.config/nvim/pack/github/start/copilot.vim`

### Windows Script Architecture

The PowerShell script (`windows/restore-windows-apps.ps1`) follows a different pattern:
- Requires Administrator privileges
- Uses both winget and Chocolatey package managers
- Enables Windows features via DISM (WSL, Virtual Machine Platform)
- Installs applications via winget (Chrome, VSCode, Obsidian, Steam, Telegram, Ubuntu)
- Installs applications via Chocolatey (Surfshark VPN, vcredist2019, Everything, Starship)
- Checks installed Microsoft Store apps via `Get-AppxPackage` and installs missing ones

## Shell Configuration Details

### .zshrc Configuration
Located in `config/shell/.zshrc`:
- Enables extensive history management (10M entries) with deduplication
- Plugins: git, sudo, history, encode64, copypath, kubectl, zsh-autosuggestions, zsh-syntax-highlighting
- Tool aliases: `cd=z` (zoxide), `cat=bat`, `lg=lazygit`, `vim=nvim`
- Custom functions: `y()` for yazi file manager with directory changing
- Integrations: starship prompt, zoxide, fzf

### Starship Configuration
Located in `config/shell/starship.toml`:
- Uses Nerd Font symbols for various language and tool indicators
- Kubernetes integration enabled
- Custom git branch styling (#ffcce1)

## Development Commands

### Testing Linux Scripts
```bash
# Arch Linux
cd linux/arch
./install-zsh-arch.sh
./config-shell-tools-arch.sh

# Ubuntu
cd linux/ubuntu
./install-zsh-ubuntu.sh
```

### Testing Windows Script
```powershell
# Run as Administrator
cd windows
.\restore-windows-apps.ps1
```

### Checking Script Syntax
```bash
# Bash scripts
bash -n <script-name>.sh

# PowerShell scripts (on Linux with pwsh)
pwsh -File <script-name>.ps1 -WhatIf
```

## Important Implementation Notes

### When Modifying Scripts

1. **Path Resolution**: Always use `SCRIPT_DIR` pattern to locate config files - never use hardcoded paths
2. **Idempotency**: Scripts should be safe to run multiple times without breaking or duplicating installations
3. **Silent Mode**: Keep all installations non-interactive for automation purposes
4. **Error Handling**: Use conditional checks (`command -v`, `[ ! -d ]`, `[ ! -e ]`) before installations
5. **Font Installation**: Hack Nerd Font v3.2.1 is the standard - URLs should point to this specific version
6. **Plugin Paths**: Zsh plugins go to `${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/`

### Configuration File Management

The config files in `config/shell/` are shared across all Linux distributions. When modifying:
- Test changes on both Arch and Ubuntu
- Ensure tool-specific configurations (like zoxide, fzf) work when tools are installed
- Keep aliases minimal and focused on common developer tools

### Package Management

**Arch** (`linux/arch/pkglist.txt`):
- Contains comprehensive system setup including GNOME desktop packages
- Includes development tools: neovim, lazygit, tmux, bat, fd, fzf, ripgrep, yazi, zoxide
- System tools: btrfs-progs, snapper, zram-generator
- ASUS-specific: asusctl, supergfxctl

**Ubuntu**: No package list file - installs are handled in scripts only
