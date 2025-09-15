# ---------- Base ----------
FROM debian:bookworm-slim

# Non-interactive APT everywhere
ENV DEBIAN_FRONTEND=noninteractive
ENV USER=root
ENV HOME="/root"
ENV TERM="xterm-256color"
ENV LANG="en_US.UTF-8"
ENV LC_ALL="en_US.UTF-8"
WORKDIR /root

# ---------- Core packages ----------
# Note: fd-find provides 'fdfind' binary; we'll symlink 'fd' below.
RUN apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends \
  curl git zsh tmux ripgrep fd-find fzf stow bat gpg build-essential ca-certificates ncurses-term locales unzip \
  && apt-get clean \
  && sed -i 's/^# *\(en_US.UTF-8 UTF-8\)/\1/' /etc/locale.gen \
  && locale-gen \
  && rm -rf /var/lib/apt/lists/*

RUN set -eux; \
  # 1) Update + base packages (includes tools we need to add a repo)
  apt-get update; \
  apt-get install -y --no-install-recommends \
  curl git zsh tmux ripgrep fd-find fzf stow bat gpg \
  build-essential ca-certificates ncurses-term locales unzip; \
  \
  # 2) Add eza repo key & list
  install -d -m 0755 /usr/share/keyrings; \
  curl -fsSL https://raw.githubusercontent.com/eza-community/eza/main/deb.asc \
  | gpg --dearmor -o /usr/share/keyrings/eza-archive-keyring.gpg; \
  echo 'deb [signed-by=/usr/share/keyrings/eza-archive-keyring.gpg] http://deb.gierens.de stable main' \
  > /etc/apt/sources.list.d/eza.list; \
  chmod 0644 /usr/share/keyrings/eza-archive-keyring.gpg /etc/apt/sources.list.d/eza.list; \
  \
  # 3) Update again (now that the new repo exists) and install eza
  apt-get update; \
  apt-get install -y --no-install-recommends eza; \
  \
  # 4) Locale & cleanup
  sed -i 's/^# *\(en_US.UTF-8 UTF-8\)/\1/' /etc/locale.gen; \
  locale-gen; \
  apt-get clean; \
  rm -rf /var/lib/apt/lists/*

# --- Neovim v0.11.3 (fixed paths) ---
ARG NEOVIM_VERSION=0.11.3

RUN set -eux; \
  arch="$(dpkg --print-architecture)"; \
  case "$arch" in \
  amd64) NVPKG="nvim-linux-x86_64.tar.gz" ;; \
  arm64) NVPKG="nvim-linux-arm64.tar.gz"  ;; \
  *) echo "Unsupported arch: $arch" >&2; exit 1 ;; \
  esac; \
  curl -fL -o /tmp/nvim.tar.gz \
  "https://github.com/neovim/neovim/releases/download/v${NEOVIM_VERSION}/${NVPKG}"; \
  mkdir -p /opt; \
  tar -xzf /tmp/nvim.tar.gz -C /opt; \
  rm -f /tmp/nvim.tar.gz; \
  # Normalize extracted dir -> /opt/nvim (e.g., nvim-linux-x86_64 or nvim-linux-arm64)
  mv /opt/nvim-linux-* /opt/nvim; \
  ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim

# Alternatives and bat alias
RUN set -eux; \
  update-alternatives --install /usr/bin/vim  vim  /usr/local/bin/nvim 60; \
  update-alternatives --install /usr/bin/nvim nvim /usr/local/bin/nvim 60; \
  update-alternatives --install /usr/bin/bat  bat  /usr/bin/batcat      10

# ------------ zoxide -------------
RUN curl -sSfl https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh

# ---------- Environment ----------
ENV XDG_CONFIG_HOME="/root/.config"
ENV ZDOTDIR="/root/.config/zsh"
ENV PATH="/root/.local/bin:${PATH}"

# ---------- Zsh & dotfiles ----------
ARG DOTFILES_REPO="https://github.com/tyreesamurai/dotfiles.git"
ARG DOTFILES_BRANCH="main"

RUN git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh /root/.config/oh-my-zsh \
  && git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions /root/.config/oh-my-zsh/custom/plugins/zsh-autosuggestions \
  && git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting /root/.config/oh-my-zsh/custom/plugins/zsh-syntax-highlighting \
  # oh-my-posh to /usr/local/bin
  && curl -s https://ohmyposh.dev/install.sh | bash -s -- -d /usr/local/bin \
  # dotfiles
  && git clone --depth=1 --branch "${DOTFILES_BRANCH}" "${DOTFILES_REPO}" /root/dotfiles \
  && git config --global init.defaultBranch main \
  && cd /root/dotfiles \
  && stow -v nvim \
  && stow -v zsh \
  && stow -v tmux \
  && stow -v bin \
  && stow -v oh-my-posh || true

# ---------- Tmux plugins (best-effort non-interactive install) ----------
RUN git clone --depth=1 https://github.com/tmux-plugins/tpm /root/.config/tmux/plugins/tpm \
  && TMUX_PLUGIN_MANAGER_PATH=/root/.config/tmux/plugins \
  tmux -f /root/.config/tmux/tmux.conf start-server || true \
  && TMUX_PLUGIN_MANAGER_PATH=/root/.config/tmux/plugins \
  /root/.config/tmux/plugins/tpm/bin/install_plugins || true \
  && tmux kill-server || true

# ---------- Neovim headless bootstraps (best-effort) ----------
RUN cat >/usr/local/bin/vim <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/nvim"
MARKER="$STATE_DIR/.nvim_bootstrapped"

if [[ "${VIM_SKIP_BOOTSTRAP:-0}" != "1" && ! -f "$MARKER" ]]; then
  echo "[vim] First-time setup: installing Neovim plugins/parsers/tools..."
  nvim --headless "+Lazy! install" "+qall" || true
  nvim --headless "+TSUpdateSync" "+qall" || true
  nvim --headless "+MasonToolsInstallSync" "+qall" || true
  mkdir -p "$STATE_DIR"; touch "$MARKER"
  echo "[vim] Neovim setup complete."
fi

exec /usr/local/bin/nvim "$@"
EOF

# RUN nvim --headless "+Lazy! install" "+qall" || true \
#   && nvim --headless "+TSUpdateSync" "+qall" || true \
#   && nvim --headless "+MasonToolsInstallSync" "+qall" || true

RUN echo 'unalias vim' >> /root/dotfiles/zsh/.config/zsh/zshrc \
  && sed -i 's/\r$//' /usr/local/bin/vim \
  && chmod +x /usr/local/bin/vim \
  && update-alternatives --install /usr/bin/vim vim /usr/local/bin/vim 70 \
  && update-alternatives --set vim /usr/local/bin/vim

# ---------- Default ----------
ENTRYPOINT [ "/usr/bin/zsh" ]

