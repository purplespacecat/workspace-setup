#!/bin/bash

sudo bash -c "
  pacman -S --noconfirm yazi ffmpeg 7zip jq fd ripgrep fzf zoxide imagemagick || true
  pacman -S --noconfirm ghostty nvim luarocks || true
  pacman -S --noconfirm bat exa lazygit || true
"

git clone https://github.com/LazyVim/starter ~/.config/nvim || true
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | bash || true

git clone https://github.com/github/copilot.vim.git \
  ~/.config/nvim/pack/github/start/copilot.vim || true

. "$HOME/.nvm/nvm.sh" || true

nvm install 22 || true
```
