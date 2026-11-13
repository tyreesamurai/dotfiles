# syntax=docker/dockerfile:1

# ---------- Build arguments ----------
ARG NEOVIM_VERSION=0.11.3
ARG DOTFILES_REPO=https://github.com/tyreesamurai/dotfiles.git
ARG DOTFILES_BRANCH=main
ARG DEV_UID=1000
ARG DEV_GID=1000

FROM debian:bookworm-slim

ARG NEOVIM_VERSION
ARG DOTFILES_REPO
ARG DOTFILES_BRANCH
ARG DEV_UID
ARG DEV_GID

ENV DEBIAN_FRONTEND=noninteractive \
  LANG=en_US.UTF-8 \
  LC_ALL=en_US.UTF-8 \
  TERM=xterm-256color \
  XDG_CONFIG_HOME=/home/dev/.config \
  ZDOTDIR=/home/dev/.config/zsh \
  PATH=/home/dev/.local/bin:/usr/local/bin:$PATH

# ---------- OS packages, eza repo, Neovim, zoxide, oh-my-posh (one layer) ----------
RUN set -eux; \
  apt-get update; \
  apt-get install -y --no-install-recommends \
  curl ca-certificates gpg sudo \
  ssh git zsh tmux ripgrep fd-find fzf stow bat \
  build-essential unzip locales ncurses-term; \
  \
  # eza repo + install
  install -d -m 0755 /usr/share/keyrings; \
  curl -fsSL https://raw.githubusercontent.com/eza-community/eza/main/deb.asc \
  | gpg --dearmor -o /usr/share/keyrings/eza-archive-keyring.gpg; \
  echo 'deb [signed-by=/usr/share/keyrings/eza-archive-keyring.gpg] http://deb.gierens.de stable main' \
  > /etc/apt/sources.list.d/eza.list; \
  chmod 0644 /usr/share/keyrings/eza-archive-keyring.gpg /etc/apt/sources.list.d/eza.list; \
  apt-get update; \
  apt-get install -y --no-install-recommends eza; \
  \
  # locale
  sed -i 's/^# *\(en_US.UTF-8 UTF-8\)/\1/' /etc/locale.gen; \
  locale-gen; \
  \
  # Neovim (pinned release tarball)
  arch="$(dpkg --print-architecture)"; \
  case "$arch" in \
  amd64) NVPKG=nvim-linux-x86_64.tar.gz ;; \
  arm64) NVPKG=nvim-linux-arm64.tar.gz  ;; \
  *) echo "Unsupported arch: $arch" >&2; exit 1 ;; \
  esac; \
  curl -fL -o /tmp/nvim.tar.gz \
  "https://github.com/neovim/neovim/releases/download/v${NEOVIM_VERSION}/${NVPKG}"; \
  mkdir -p /opt; \
  tar -xzf /tmp/nvim.tar.gz -C /opt; \
  mv /opt/nvim-linux-* /opt/nvim; \
  ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim; \
  rm -f /tmp/nvim.tar.gz; \
  \
  # zoxide + oh-my-posh (curl | sh — see note in chat re: supply-chain risk)
  curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh; \
  curl -s https://ohmyposh.dev/install.sh | bash -s -- -d /usr/local/bin; \
  \
  # alternatives
  update-alternatives --install /usr/bin/vim  vim  /usr/local/bin/nvim 60; \
  update-alternatives --install /usr/bin/nvim nvim /usr/local/bin/nvim 60; \
  update-alternatives --install /usr/bin/bat  bat  /usr/bin/batcat      10; \
  \
  apt-get clean; \
  rm -rf /var/lib/apt/lists/*

# ---------- Headless-bootstrap vim wrapper (root-owned, any user can run it) ----------
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
RUN chmod +x /usr/local/bin/vim \
  && update-alternatives --install /usr/bin/vim vim /usr/local/bin/vim 70 \
  && update-alternatives --set vim /usr/local/bin/vim

# ---------- Non-root dev user ----------
# NOPASSWD sudo is a convenience trade-off for a personal dev image (ad hoc apt-get
# installs without a rebuild). Drop the sudoers line entirely if you'd rather rebuild
# the image whenever you need a new package — that's the stricter CKS-aligned option.
RUN groupadd -g ${DEV_GID} dev \
  && useradd -m -u ${DEV_UID} -g ${DEV_GID} -s /usr/bin/zsh dev \
  && echo "dev ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/dev \
  && chmod 0440 /etc/sudoers.d/dev

USER dev
WORKDIR /home/dev

# ---------- Dotfiles, oh-my-zsh, tmux plugins (one layer, runs as dev) ----------
RUN git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh "${XDG_CONFIG_HOME}/oh-my-zsh" \
  && git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions \
  "${XDG_CONFIG_HOME}/oh-my-zsh/custom/plugins/zsh-autosuggestions" \
  && git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting \
  "${XDG_CONFIG_HOME}/oh-my-zsh/custom/plugins/zsh-syntax-highlighting" \
  && git clone --depth=1 --branch "${DOTFILES_BRANCH}" "${DOTFILES_REPO}" /home/dev/dotfiles \
  && git config --global init.defaultBranch main \
  && cd /home/dev/dotfiles \
  && stow -v nvim zsh tmux bin oh-my-posh || true \
  && echo 'unalias vim' >> /home/dev/dotfiles/zsh/.config/zsh/zshrc \
  && git clone --depth=1 https://github.com/tmux-plugins/tpm "${XDG_CONFIG_HOME}/tmux/plugins/tpm" \
  && TMUX_PLUGIN_MANAGER_PATH="${XDG_CONFIG_HOME}/tmux/plugins" \
  tmux -f "${XDG_CONFIG_HOME}/tmux/tmux.conf" start-server || true \
  && TMUX_PLUGIN_MANAGER_PATH="${XDG_CONFIG_HOME}/tmux/plugins" \
  "${XDG_CONFIG_HOME}/tmux/plugins/tpm/bin/install_plugins" || true \
  && tmux kill-server || true

# ---------- Default ----------
ENTRYPOINT [ "/usr/bin/zsh" ]
