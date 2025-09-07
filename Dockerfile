
# ---------- Base ----------
FROM docker.io/debian:bookworm

# Non-interactive APT everywhere
ENV DEBIAN_FRONTEND=noninteractive
ENV user=root
ENV TERM="xterm-256color"
ENV LANG="en_US.UTF-8"
ENV LC_ALL="en_US.UTF-8"

# ---------- Core packages ----------
# Note: fd-find provides 'fdfind' binary; we'll symlink 'fd' below.
RUN apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends \
  curl git zsh tmux ripgrep fd-find fzf stow bat build-essential pkg-config ca-certificates ncurses-term locales unzip \
  && apt-get clean \
  && sed -i 's/^# *\(en_US.UTF-8 UTF-8\)/\1/' /etc/locale.gen \
  && locale-gen \
  && rm -rf /var/lib/apt/lists/*

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
  && cd /root/dotfiles \
  && stow -v nvim \
  && stow -v zsh \
  && stow -v tmux \
  && stow -v oh-my-posh || true

# ---------- Tmux plugins (best-effort non-interactive install) ----------
RUN git clone --depth=1 https://github.com/tmux-plugins/tpm /root/.config/tmux/plugins/tpm \
  && TMUX_PLUGIN_MANAGER_PATH=/root/.config/tmux/plugins \
  tmux -f /root/.config/tmux/tmux.conf start-server || true \
  && TMUX_PLUGIN_MANAGER_PATH=/root/.config/tmux/plugins \
  /root/.config/tmux/plugins/tpm/bin/install_plugins || true \
  && tmux kill-server || true

# ---------- Neovim headless bootstraps (best-effort) ----------
# If your config expects external runtimes (node/go/python), consider adding them, or ignore failures.
RUN nvim --headless "+Lazy! install" "+qall" || true \
  && nvim --headless "+TSUpdateSync" "+qall" || true \
  && nvim --headless "+MasonToolsInstallSync" "+qall" || true

# ---------- Default ----------
ENTRYPOINT [ "/usr/bin/zsh" ]

