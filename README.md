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
├── install               # runs Dotbot; downloads it into dotbot/ on first run
├── install.conf.yaml     # Dotbot mapping: where each file gets linked
├── .gitignore            # ignores dotbot/
├── ansible/
│   └── site.yml          # Fedora bootstrap playbook (run with ansible-pull)
└── zsh/
    ├── zshenv            # -> ~/.zshenv
    ├── zshrc             # -> ~/.config/zsh/.zshrc
    ├── aliases.zsh       # -> ~/.config/zsh/aliases.zsh
    ├── functions.zsh     # -> ~/.config/zsh/functions.zsh
    └── os.zsh            # linux / macos branches only
```

Other tools (`nvim/`, `ghostty/`, `starship/`, `tmux/`, ...) get their own
top-level folder the same way.

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

Machine-specific settings (work VM, a single laptop) go in
`~/.config/zsh/local.zsh` on that machine. It's loaded if present and is never
committed.

## How linking works

`install.conf.yaml` maps targets to files in this repo:

```yaml
- defaults:
    link:
      create: true # make parent folders like ~/.config
      relink: true

- link:
    ~/.zshenv: zsh/zshenv
    ~/.config/zsh/.zshrc: zsh/zshrc
    ~/.config/zsh/:
      glob: true
      path: zsh/*.zsh
```

Run `./install` to create the links. Dotbot isn't stored in this repo (no
submodule): the first run clones it into `dotbot/`, which is gitignored, and
later runs reuse it. The only requirements are `git` and `python3`. Re-run
`./install` after adding a new file or mapping. Links point into this repo, so
editing `~/.config/zsh/aliases.zsh` edits the file here.

To pass a different config (for example on the work VM):
`./install install-work.conf.yaml`.

To upgrade Dotbot: change `DOTBOT_VERSION` in `install`, delete `dotbot/`, run
`./install`.

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

1. Installs packages with dnf.
2. Downloads starship and lazygit from their GitHub releases into
   `~/.local/opt/<tool>-<version>/` and links them into `~/.local/bin`.
3. Runs `./install` to link the dotfiles.
4. Sets zsh as the login shell.

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
git clone -b macos https://github.com/tyreesamurai/dotfiles.git ~/.dotfiles
~/.dotfiles/install
```

### Ubuntu

The playbook is Fedora-only. Install the apt / bin column of
[INVENTORY.md](INVENTORY.md) (note the [name gotchas](INVENTORY.md#name-gotchas)),
then clone the `linux` branch and run `./install`.

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
