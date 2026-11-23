# dotfiles

My shell, editor and tool config for macOS and Linux (Fedora first, Ubuntu
supported). Files live in plain per-tool folders (`zsh/`, `nvim/`, ...) and
[Dotbot](https://github.com/anishathalye/dotbot) links them to wherever each
tool expects them, using one mapping file.

- **What to install:** see [INVENTORY.md](INVENTORY.md) for every tool these
  dotfiles expect, the minimum versions, and the Homebrew / apt / dnf names.
- **Fresh Fedora machine:** one `ansible-pull` command. See
  [Bootstrapping a machine](#bootstrapping-a-machine).
- **Testing:** the [Dockerfile](Dockerfile) builds a throwaway Fedora box
  to run the whole bootstrap against. See [Testing in a container](#testing-in-a-container).

---

## Layout

```text
.
├── README.md
├── INVENTORY.md          # every required tool + brew/apt/dnf package names
├── Dockerfile            # Fedora test image (base + final stages)
├── install.conf.yaml     # Dotbot mapping: where each file gets linked
├── .gitignore            # ignores files tools generate inside the repo (tmux/plugins/)
├── ansible/
│   └── site.yml          # Fedora bootstrap playbook (run with ansible-pull)
├── zsh/
│   ├── zshenv            # -> ~/.zshenv
│   ├── zshrc             # -> ~/.config/zsh/.zshrc
│   ├── aliases.zsh       # -> ~/.config/zsh/aliases.zsh
│   ├── functions.zsh     # -> ~/.config/zsh/functions.zsh
│   └── os.zsh            # linux / macos branches only
├── nvim/                 # -> ~/.config/nvim (LazyVim)
├── tmux/
│   └── tmux.conf         # -> ~/.config/tmux/tmux.conf
├── git/
│   ├── config            # -> ~/.config/git/config
│   └── ignore            # -> ~/.config/git/ignore (global gitignore)
└── bin/                  # each script -> ~/.local/bin/<name>
```

Other tools (`ghostty/`, `starship/`, ...) get their own top-level folder the
same way.

## Branches

| Branch  | What's on it                                                             |
| ------- | ------------------------------------------------------------------------ |
| `main`  | Everything shared between macOS and Linux. No OS-specific code.          |
| `linux` | `main` + `zsh/os.zsh` with Linux-only aliases, functions and fixes       |
| `macos` | `main` + `zsh/os.zsh` for macOS, plus `zsh/zprofile` (Homebrew shellenv) |

Workflow:

1. Make shared changes on `main`.
2. Bring them into each OS branch: `git switch linux && git merge main`
   (same for `macos`).
3. Put OS-specific changes in `os.zsh` on that branch. Avoid editing
   `aliases.zsh` / `functions.zsh` on a branch, or merges from `main` will
   conflict.

## Machine-specific settings

Anything that only applies to one machine (the work VM, a single laptop) lives
on that machine and is never committed. Each one is loaded only if it exists.

| File                         | Loaded by                                 | Typical use                      |
| ---------------------------- | ----------------------------------------- | -------------------------------- |
| `~/.config/zsh/local.zsh`    | `zshrc`                                   | Work-only aliases, proxies, PATH |
| `~/.config/git/config.local` | `[include]` at the bottom of `git/config` | Work email, credential helpers   |

Tools that run `git config --global` (for example `gh auth setup-git`) write
into `git/config` here, because it's a link into this repo. Check `git diff`
after setting up a new tool, and move anything machine-specific into
`config.local`.

## How linking works

`install.conf.yaml` maps targets to files in this repo:

```yaml
- defaults:
    link:
      create: true # make parent folders like ~/.config
      relink: true # replace existing symlinks (including old Stow ones)

- clean: ["~", "~/.config", "~/.local/bin"] # remove dead links into this repo

- link:
    ~/.zshenv: zsh/zshenv
    ~/.config/zsh/.zshrc: zsh/zshrc
    ~/.config/zsh/:
      glob: true
      path: zsh/*.zsh
    ~/.config/nvim: nvim
    ~/.config/tmux/tmux.conf: tmux/tmux.conf
    ~/.config/git/:
      glob: true
      path: git/*
    ~/.local/bin/:
      glob: true
      path: bin/*
```

Dotbot is installed as a normal command, not stored in this repo. Run it from
the repo root:

```bash
dotbot -c install.conf.yaml
```

Or from anywhere: `dotbot -d ~/.dotfiles -c ~/.dotfiles/install.conf.yaml`.

Re-run it after adding a new file or mapping; it's safe to run as often as you
like. Links point into this repo, so editing `~/.config/zsh/aliases.zsh` edits
the file here.

To use a different mapping (for example on the work VM):
`dotbot -c install-work.conf.yaml`.

Rules that keep the links sane:

- **Link files, not folders that tools write into.** `~/.config/tmux` is a real
  folder with only `tmux.conf` linked, so TPM's plugins land in
  `~/.config/tmux/plugins/` and not in this repo. `nvim/` is linked as a whole
  folder on purpose: everything Neovim writes goes to `~/.local/share/nvim`.
- **Use `glob` for shared folders.** `~/.local/bin` and `~/.config/git` also
  hold files that aren't mine (`claude`, `config.local`). Globbing links each
  repo file individually and leaves the rest alone.
- **Don't use `force: true`.** It deletes whatever real file or folder is at
  the target. If Dotbot reports that a target exists, move it aside and re-run.

To install or upgrade Dotbot itself:

| OS    | Install                                             | Upgrade               |
| ----- | --------------------------------------------------- | --------------------- |
| macOS | `brew install dotbot`                               | `brew upgrade dotbot` |
| Linux | `pipx install dotbot` (or `uv tool install dotbot`) | `pipx upgrade dotbot` |

## Zsh

- **`zshenv`** sets the XDG folders and `ZDOTDIR=~/.config/zsh`, so zsh reads
  the rest of its config from there. It's the only zsh file in `$HOME`.
- **`zshrc`** has sections for environment, history and options, completion,
  tool integrations (fzf, zoxide, starship) and plugins. It sources the files
  below in the middle.
- **`aliases.zsh`** and **`functions.zsh`** hold shared aliases and functions
  (`git` with no args opens lazygit; `refresh-completions` rebuilds the
  completion cache).
- **`os.zsh`** exists only on the OS branches.
- **`local.zsh`** lives only on a machine, never in the repo.

History is kept in `~/.local/state/zsh/history`, and caches (completions,
`zcompdump`) in `~/.cache/zsh/`.

## Neovim

LazyVim, trimmed to what I actually use. Every file in `nvim/lua/plugins/`
starts with a `-- why:` comment, and anything without a reason gets removed.

- `lazy-lock.json` is committed, so every machine gets the same plugin versions.
  Run `:Lazy restore` after pulling to match it.
- Treesitter parsers are compiled on each machine, which needs the
  `tree-sitter` CLI and a C compiler (see [INVENTORY.md](INVENTORY.md)). If
  highlighting breaks or the `:` cmdline flickers with query errors, run
  `:checkhealth nvim-treesitter`, then `:TSUpdate`.
- To try a config change without touching the real one, put a copy in
  `~/.config/nvim-test` and run `NVIM_APPNAME=nvim-test nvim`. It gets its own
  plugins and data.

## Tmux

- [TPM](https://github.com/tmux-plugins/tpm) installs itself and the plugins
  on the first tmux start, into `~/.config/tmux/plugins/` (ignored, not in
  this repo). After changing the plugin list: `prefix + I` to install,
  `prefix + Alt+u` to remove dropped plugins.
- The Catppuccin theme is pinned to a release tag in `tmux.conf`. To upgrade:
  change the tag, delete `~/.config/tmux/plugins/tmux`, then `prefix + I`.
- `prefix + r` reloads the config.

## Bootstrapping a machine

### Fedora (home server, Linux desktops)

Install what Ansible needs, then let `ansible-pull` clone this repo to
`~/.dotfiles` and run the playbook from it:

```bash
sudo dnf install -y ansible-core python3-libdnf5 git
ansible-pull -U https://github.com/tyreesamurai/dotfiles.git -C linux \
  -d ~/.dotfiles ansible/site.yml -K
```

`-K` asks for your sudo password. The playbook:

1. Installs packages with dnf, including `pipx`.
2. Installs Dotbot with pipx.
3. Downloads starship and lazygit from their GitHub releases into
   `~/.local/opt/<tool>-<version>/` and links them into `~/.local/bin`.
4. Runs `dotbot -c install.conf.yaml` to link the dotfiles.
5. Sets zsh as the login shell.

It's safe to re-run: a second run should end with `changed=0`. Re-running is
also how you update a machine after pushing changes.

To upgrade starship or lazygit, change `starship_version` / `lazygit_version`
at the top of `ansible/site.yml` and re-run (only those tasks:
`--tags tools`).

### macOS

There's no macOS playbook yet (`ansible.builtin.package` doesn't support
Homebrew; a `macos`-branch playbook would use `community.general.homebrew`).
For now:

```bash
xcode-select --install          # compiler, git, python3
# install Homebrew from https://brew.sh, then the brew column of INVENTORY.md
brew install dotbot
git clone -b macos https://github.com/tyreesamurai/dotfiles.git ~/.dotfiles
cd ~/.dotfiles && dotbot -c install.conf.yaml
```

### Ubuntu

The playbook is Fedora-only. Install the apt / bin column of
[INVENTORY.md](INVENTORY.md) (note the [name gotchas](INVENTORY.md#name-gotchas)),
then:

```bash
sudo apt install -y pipx && pipx ensurepath
pipx install dotbot
git clone -b linux https://github.com/tyreesamurai/dotfiles.git ~/.dotfiles
cd ~/.dotfiles && dotbot -c install.conf.yaml
```

## Testing in a container

The [Dockerfile](Dockerfile) has two stages:

| Stage   | What it is                                                                    | Use it to                                    |
| ------- | ----------------------------------------------------------------------------- | -------------------------------------------- |
| `base`  | Bare Fedora 45 + Ansible's requirements + user `tyree` with passwordless sudo | Run `ansible-pull` by hand and watch it work |
| `final` | `base` with `ansible-pull` already applied                                    | Get a finished image to poke around in       |

Everything comes from GitHub, so **push your changes before testing**.

Run the playbook by hand:

```bash
docker build --target base -t dotfiles:base .
docker run --rm -it dotfiles:base

# inside the container:
ansible-pull -U https://github.com/tyreesamurai/dotfiles.git -C linux \
  -d ~/.dotfiles ansible/site.yml
ansible-pull -U https://github.com/tyreesamurai/dotfiles.git -C linux \
  -d ~/.dotfiles ansible/site.yml   # second run: expect changed=0
zsh
```

Build the finished image:

```bash
docker build -t dotfiles:final --build-arg CACHEBUST=$(date +%s) .
docker run --rm -it dotfiles:final
```

`CACHEBUST` forces a fresh pull; without it, the build reuses a cached layer
and won't see new commits. Other build args: `FEDORA_VERSION`,
`DOTFILES_REPO`, `DOTFILES_BRANCH`.

Podman works too: swap `docker` for `podman` in the commands above.

Once in the shell, the check script at the bottom of
[INVENTORY.md](INVENTORY.md#check-whats-installed) shows what's installed and
what's missing.

## Troubleshooting

**A whole folder got linked instead of one file** (for example tool data
showing up in this repo). Replace the folder link with a real folder, then
re-run Dotbot:

```bash
ls -ld ~/.config/tmux      # shows "-> .../dotfiles/tmux" if it's a folder link
rm ~/.config/tmux          # no trailing slash, no -rf: removes only the link
mkdir -p ~/.config/tmux
dotbot -c install.conf.yaml
```

`rm -rf ~/.config/tmux/` with a trailing slash would follow the link and
delete the files in this repo.

**Dotbot says a target already exists.** A real file or folder is in the way.
Move it aside (`mv ~/.config/foo ~/.config/foo.old`) and re-run.

**Check where every git setting comes from:**
`git config --list --show-origin --global`.
