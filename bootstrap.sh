#!/bin/bash

set -euo pipefail

dnf install -y \
  git neovim tmux zsh stow \
  curl wget unzip tar gzip \
  fzf fd-find ripgrep \
  gcc gcc-c++ make cmake \
  python3 python3-pip \
  nodejs npm \
  go rust cargo

mkdir -p \
  ~/.config \
  ~/.local/bin \
  ~/.local/share \
  ~/.cache

command -v zoxide >/dev/null || sudo dnf install -y zoxide
command -v eza >/dev/null || cargo install eza

export ZSH="$HOME/.config/oh-my-zsh"
RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "$HOME"/.config/oh-my-zsh/custom/plugins/zsh-autosuggestions &&
  git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting "$HOME"/.config/oh-my-zsh/custom/plugins/zsh-syntax-highlighting

command -v oh-my-posh >/dev/null ||
  curl -s https://ohmyposh.dev/install.sh | sudo bash -s -- -d /usr/local/bin

git clone --depth=1 https://github.com/tyreesamurai/dotfiles "$HOME"/dotfiles &&
  stow -d "$HOME"/dotfiles -v zsh tmux oh-my-posh bin nvim

git clone --depth=1 https://github.com/tmux-plugins/tpm "$HOME"/.config/tmux/plugins/tpm
export TMUX_PLUGIN_MANAGER_PATH="$HOME"/.config/tmux/plugins
tmux -f "$HOME"/.config/tmux/tmux.conf start-server
"$HOME"/.config/tmux/plugins/tpm/bin/install_plugins
tmux kill-server
