#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR/../../config/shell"

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

TYPES=()
DESCS=()
DETAILS=()

flag() {
  TYPES+=("$1")
  DESCS+=("$2")
  DETAILS+=("$3")
}

check_dotfile() {
  local label="$1" src="$2" dst="$3"
  if [ ! -f "$dst" ]; then
    flag "copy" "${RED}MISSING${NC}    $label ($dst)" "$src|$dst"
  elif ! diff -q "$src" "$dst" &>/dev/null; then
    flag "copy" "${YELLOW}OUTDATED${NC}   $label (differs from repo)" "$src|$dst"
  fi
}

check_tool() {
  local cmd="$1" label="${2:-$1}" install_hint="$3"
  if ! command -v "$cmd" &>/dev/null; then
    flag "tool" "${RED}MISSING${NC}    tool: $label" "$install_hint"
  fi
}

check_plugin() {
  local name="$1" url="$2"
  local path="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/$name"
  if [ ! -d "$path" ]; then
    flag "plugin" "${RED}MISSING${NC}    OMZ plugin: $name" "$url|$path"
  fi
}

# --- Dotfile checks ---
check_dotfile ".zshrc"         "$CONFIG_DIR/.zshrc"         "$HOME/.zshrc"
check_dotfile "starship.toml"  "$CONFIG_DIR/starship.toml"  "$HOME/.config/starship.toml"
check_dotfile ".tmux.conf"     "$CONFIG_DIR/.tmux.conf"     "$HOME/.tmux.conf"

# --- Oh My Zsh ---
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  flag "omz" "${RED}MISSING${NC}    oh-my-zsh (~/.oh-my-zsh)" ""
fi

# --- OMZ plugins ---
check_plugin "zsh-autosuggestions"   "https://github.com/zsh-users/zsh-autosuggestions"
check_plugin "zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting.git"

# --- Tools referenced in .zshrc ---
check_tool "starship"  "starship"  "curl -sS https://starship.rs/install.sh | sh -s -- -y"
check_tool "zoxide"    "zoxide"    "sudo dnf install -y zoxide"
check_tool "bat"       "bat"       "sudo dnf install -y bat"
check_tool "nvim"      "neovim"    "see config-shell-tools-fedora.sh"
check_tool "lazygit"   "lazygit"   "see config-shell-tools-fedora.sh"
check_tool "yazi"      "yazi"      "see config-shell-tools-fedora.sh"
check_tool "fzf"       "fzf"       "git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install"

# fzf shell integration (.fzf.zsh must exist for .zshrc to source it)
if command -v fzf &>/dev/null && [ ! -f "$HOME/.fzf.zsh" ]; then
  flag "fzf_int" "${YELLOW}MISSING${NC}    fzf shell integration (~/.fzf.zsh)" ""
fi

# --- Present results ---
if [ ${#DESCS[@]} -eq 0 ]; then
  echo -e "${GREEN}All dotfiles and tools look healthy.${NC}"
  exit 0
fi

echo -e "\n${CYAN}Dotfile health check — ${#DESCS[@]} issue(s) found:${NC}\n"
for i in "${!DESCS[@]}"; do
  echo -e "  [$((i+1))] ${DESCS[$i]}"
done

fix_issue() {
  local i="$1"
  local type="${TYPES[$i]}" detail="${DETAILS[$i]}" desc="${DESCS[$i]}"
  echo -e "\n${GREEN}Fixing:${NC} $(echo -e "$desc" | sed 's/\x1b\[[0-9;]*m//g')"

  case "$type" in
    copy)
      local src="${detail%%|*}" dst="${detail##*|}"
      mkdir -p "$(dirname "$dst")"
      cp "$src" "$dst"
      echo "  Copied: $src → $dst"
      ;;
    tool)
      echo "  Install hint: $detail"
      echo "  (run hint manually or re-run config-shell-tools-fedora.sh)"
      ;;
    plugin)
      local url="${detail%%|*}" path="${detail##*|}"
      git clone "$url" "$path"
      ;;
    omz)
      sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
      ;;
    fzf_int)
      if [ -d "$HOME/.fzf" ]; then
        "$HOME/.fzf/install" --all --no-bash --no-fish
      else
        echo "  fzf was installed via dnf — shell integration not set up."
        echo "  Run config-shell-tools-fedora.sh to reinstall fzf via git with shell integration."
      fi
      ;;
  esac
}

echo ""
read -rp "Fix all? [y]es / [s]elect / [n]o: " choice

case "$choice" in
  [Yy]*)
    for i in "${!TYPES[@]}"; do fix_issue "$i"; done
    ;;
  [Ss]*)
    for i in "${!DESCS[@]}"; do
      echo -e ""
      read -rp "Fix [$((i+1))] $(echo -e "${DESCS[$i]}" | sed 's/\x1b\[[0-9;]*m//g')? [y/N] " pick
      [[ "$pick" =~ ^[Yy] ]] && fix_issue "$i"
    done
    ;;
  *)
    echo "No changes made."
    exit 0
    ;;
esac

echo -e "\n${GREEN}Done. Restart your shell or run: source ~/.zshrc${NC}"
