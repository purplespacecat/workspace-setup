#!/usr/bin/env bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

check_command() {
    if command -v "$1" >/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} $1 is installed"
        return 0
    else
        echo -e "${RED}✗${NC} $1 is not installed"
        return 1
    fi
}

check_file() {
    if [ -e "$1" ]; then
        echo -e "${GREEN}✓${NC} $1 exists"
        return 0
    else
        echo -e "${RED}✗${NC} $1 does not exist"
        return 1
    fi
}

check_directory() {
    if [ -d "$1" ]; then
        echo -e "${GREEN}✓${NC} $1 directory exists"
        return 0
    else
        echo -e "${RED}✗${NC} $1 directory does not exist"
        return 1
    fi
}

test_shell_setup() {
    echo "Testing shell setup..."
    local errors=0
    
    # Check shell
    if [ "$SHELL" = "/usr/bin/zsh" ]; then
        echo -e "${GREEN}✓${NC} ZSH is default shell"
    else
        echo -e "${RED}✗${NC} ZSH is not default shell"
        ((errors++))
    fi
    
    # Check required commands
    local commands=(zsh git starship bat fzf tmux nvim)
    for cmd in "${commands[@]}"; do
        check_command "$cmd" || ((errors++))
    done
    
    # Check configuration files
    local files=(
        "$HOME/.zshrc"
        "$HOME/.config/starship.toml"
    )
    for file in "${files[@]}"; do
        check_file "$file" || ((errors++))
    done
    
    # Check directories
    local dirs=(
        "$HOME/.oh-my-zsh"
        "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
        "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
    )
    for dir in "${dirs[@]}"; do
        check_directory "$dir" || ((errors++))
    done
    
    return $errors
}

test_backup_restore() {
    echo "Testing backup and restore functionality..."
    local errors=0
    local test_backup="$HOME/test-backup-$(date +%s).tar.gz"
    
    # Test backup creation
    echo "Creating test backup..."
    ./backup-system.sh
    if [ -f "$HOME/system-backup/$(date +%Y-%m-%d).tar.gz" ]; then
        echo -e "${GREEN}✓${NC} Backup created successfully"
        cp "$HOME/system-backup/$(date +%Y-%m-%d).tar.gz" "$test_backup"
    else
        echo -e "${RED}✗${NC} Backup creation failed"
        ((errors++))
    fi
    
    # Test backup contents
    echo "Testing backup contents..."
    local temp_dir=$(mktemp -d)
    tar -xzf "$test_backup" -C "$temp_dir"
    
    # Check for essential backup components
    local backup_files=(
        ".zshrc"
        ".config/starship.toml"
        "systemd-services"
    )
    
    for file in "${backup_files[@]}"; do
        if find "$temp_dir" -name "$(basename "$file")" | grep -q .; then
            echo -e "${GREEN}✓${NC} Found $file in backup"
        else
            echo -e "${RED}✗${NC} Missing $file in backup"
            ((errors++))
        fi
    done
    
    # Cleanup
    rm -rf "$temp_dir" "$test_backup"
    
    return $errors
}

main() {
    echo "Starting system setup tests..."
    local total_errors=0
    
    # Test shell setup
    test_shell_setup
    total_errors=$((total_errors + $?))
    
    # Test backup/restore
    test_backup_restore
    total_errors=$((total_errors + $?))
    
    # Final results
    echo "---------------------"
    if [ $total_errors -eq 0 ]; then
        echo -e "${GREEN}All tests passed!${NC}"
        exit 0
    else
        echo -e "${RED}$total_errors test(s) failed${NC}"
        exit 1
    fi
}

main "$@"