#!/bin/bash

sudo pacman -S --needed - < pkglist.txt

git clone https://github.com/LazyVim/starter ~/.config/nvim || true
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | bash || true

git clone https://github.com/github/copilot.vim.git \
  ~/.config/nvim/pack/github/start/copilot.vim || true

. "$HOME/.nvm/nvm.sh" || true

nvm install 22 || true
```
