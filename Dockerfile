# Test machine for the dotfiles playbook. Everything comes from GitHub.
#
#   podman build --target base -t dotfiles:base .   # bare Fedora, run ansible-pull by hand
#   podman build -t dotfiles:final --build-arg CACHEBUST=$(date +%s) .
#                                                   # Fedora with the playbook applied

ARG FEDORA_VERSION=45

# ---- Stage 1: a fresh Fedora box with only what Ansible needs ----------------
FROM registry.fedoraproject.org/fedora:${FEDORA_VERSION} AS base

RUN dnf install -y ansible-core python3-libdnf5 git sudo shadow-utils \
 && dnf clean all

# A normal user with passwordless sudo, like you on the home server
RUN useradd -m tyree \
 && echo 'tyree ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/tyree

USER tyree
WORKDIR /home/tyree
CMD ["/bin/bash"]

# ---- Stage 2: same box, with ansible-pull run against it ---------------------
FROM base AS final

ARG DOTFILES_REPO=https://github.com/tyreesamurai/dotfiles.git
ARG DOTFILES_BRANCH=linux
# Change this value to force a fresh pull instead of a cached layer
ARG CACHEBUST=1

RUN ansible-pull -U "$DOTFILES_REPO" -C "$DOTFILES_BRANCH" \
      -d /home/tyree/.dotfiles ansible/site.yml

CMD ["/bin/zsh"]
