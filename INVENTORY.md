# Dotfiles Software Inventory

Everything these dotfiles expect to find on a machine. **Minimum** is the
oldest version known to work with this config; newer is fine (and preferred).

Install methods:

- **brew**: Homebrew on macOS. `tap/name` means a third-party tap
  (`brew install hashicorp/tap/terraform` adds the tap automatically);
  `--cask` means a GUI app, font or prebuilt bundle.
- **pkg**: Linux system package manager (`apt` on Ubuntu, `dnf` on Fedora)
- **bin**: release tarball, binary placed in `~/.local/bin`
- **built in**: ships with the OS, nothing to install
- Where Ubuntu's packaged version is often too old, prefer **bin** on Ubuntu.
  Fedora's packages and Homebrew are usually current enough.

On Fedora, `ansible/site.yml` installs the rows marked **(playbook)**. Everything
else is installed by hand for now. See the [README](README.md#bootstrapping-a-machine).

---

## Bootstrap (required)

| Tool              | Minimum | Why this minimum                                                     | macOS (brew)                         | Ubuntu (apt)      | Fedora (dnf)                   |
| ----------------- | ------- | -------------------------------------------------------------------- | ------------------------------------ | ----------------- | ------------------------------ |
| Homebrew          | any     | Package manager for everything else on macOS                         | install script from brew.sh          | n/a               | n/a                            |
| git               | 2.37    | `push.autoSetupRemote` (2.37), `merge.conflictstyle = zdiff3` (2.35) | `git`                                | `git`             | `git` (playbook)               |
| python3           | 3.x     | Runs Dotbot (`./install`) and Ansible                                | built in (Xcode CLT)                 | `python3`         | built in                       |
| Dotbot            | 1.24    | Links the dotfiles. `./install` downloads it into `dotbot/`          | none needed                          | none needed       | none needed                    |
| ansible-core      | 2.15    | Runs `ansible/site.yml`; 2.15 added dnf5 support (Fedora 41+)        | `ansible`                            | `ansible-core`    | `ansible-core`                 |
| python3-libdnf5   | any     | Lets Ansible's `package` module drive dnf5 (Fedora 41+)              | n/a                                  | n/a               | `python3-libdnf5`              |
| curl              | any     | Downloads, API checks                                                | built in                             | `curl`            | `curl`                         |
| tar, gzip, unzip  | any     | Extracting tarballs; Neovim plugins need `unzip`                     | built in                             | `tar gzip unzip`  | `tar` (playbook), `gzip unzip` |
| C compiler + make | any     | Treesitter compiles language parsers                                 | Xcode CLT (`xcode-select --install`) | `build-essential` | `gcc gcc-c++ make`             |

## Shell

| Tool                    | Minimum | Why this minimum                                        | macOS (brew)              | Ubuntu (apt)                          | Fedora (dnf)                            |
| ----------------------- | ------- | ------------------------------------------------------- | ------------------------- | ------------------------------------- | --------------------------------------- |
| zsh                     | 5.8     | General config                                          | built in (or `zsh`)       | `zsh`                                 | `zsh` (playbook)                        |
| zsh-autosuggestions     | 0.7     | Sourced from `/usr/share/` or `$(brew --prefix)/share/` | `zsh-autosuggestions`     | `zsh-autosuggestions`                 | `zsh-autosuggestions` (playbook)        |
| zsh-syntax-highlighting | 0.7     | Same lookup as above; must load last                    | `zsh-syntax-highlighting` | `zsh-syntax-highlighting`             | `zsh-syntax-highlighting` (playbook)    |
| starship                | 1.20    | `[[kubernetes.contexts]]` syntax in `starship.toml`     | `starship`                | **bin**                               | **bin** (playbook; not in Fedora repos) |
| fzf                     | 0.48    | `source <(fzf --zsh)`                                   | `fzf`                     | **bin** (apt is usually too old)      | `fzf` (playbook)                        |
| zoxide                  | recent  | `zoxide init --cmd cd zsh`                              | `zoxide`                  | `zoxide` or bin                       | `zoxide` (playbook)                     |
| eza                     | any     | `ls` aliases (`--git`, `--group-directories-first`)     | `eza`                     | `eza` (24.04+) or bin                 | `eza` (playbook)                        |
| bat                     | any     | `cat` alias, fzf previews                               | `bat`                     | **bin** (apt installs it as `batcat`) | `bat` (playbook)                        |
| tmux                    | 3.2     | Popup windows (3.2+)                                    | `tmux`                    | `tmux`                                | `tmux`                                  |

## Editor (Neovim / LazyVim)

| Tool            | Minimum | Why this minimum                                                            | macOS (brew)                           | Ubuntu (apt)                          | Fedora (dnf)                       |
| --------------- | ------- | --------------------------------------------------------------------------- | -------------------------------------- | ------------------------------------- | ---------------------------------- |
| neovim          | 0.11.2  | Required by current LazyVim; `MANPAGER='nvim +Man!'`                        | `neovim`                               | **bin** (apt is too old)              | `neovim` (playbook)                |
| tree-sitter CLI | 0.25    | Newer LazyVim (nvim-treesitter `main` branch) compiles parsers with it      | `tree-sitter-cli`                      | bin                                   | `tree-sitter-cli` or bin           |
| ripgrep (`rg`)  | any     | LazyVim live grep                                                           | `ripgrep`                              | `ripgrep`                             | `ripgrep` (playbook)               |
| fd              | 8.0     | LazyVim file finder                                                         | `fd`                                   | **bin** (apt installs it as `fdfind`) | `fd-find` (playbook; runs as `fd`) |
| lazygit         | 0.40    | `git` with no args, `<leader>gg` in LazyVim                                 | `lazygit`                              | bin                                   | **bin** (playbook)                 |
| Nerd Font       | v3      | Icons. Install on the machine running the **terminal**, not the remote host | `--cask font-jetbrains-mono-nerd-font` | n/a                                   | n/a                                |

## Kubernetes / cloud (work + homelab)

| Tool           | Minimum                      | Why this minimum                                             | macOS (brew)                | Ubuntu (apt)       | Fedora (dnf)       |
| -------------- | ---------------------------- | ------------------------------------------------------------ | --------------------------- | ------------------ | ------------------ |
| kubectl        | cluster version ±1 minor     | Kubernetes version skew policy. Match each cluster           | `kubectl`                   | bin                | bin                |
| kubelogin      | any                          | Only for AKS clusters with Entra ID login                    | `Azure/kubelogin/kubelogin` | bin                | bin                |
| az (Azure CLI) | recent                       | Login, Key Vault, AKS credentials                            | `--cask azure-cli`          | Microsoft apt repo | Microsoft dnf repo |
| terraform      | per repo                     | Check `required_version` in the repo's `.tf` files           | `hashicorp/tap/terraform`   | bin                | bin                |
| flux           | match cluster's Flux version | GitOps CLI                                                   | `fluxcd/tap/flux`           | bin                | bin                |
| helm           | 3.x                          | Optional                                                     | `helm`                      | bin                | `helm` or bin      |
| k9s            | any                          | Optional TUI                                                 | `k9s`                       | bin                | bin                |
| jq             | 1.6                          | JSON on the command line                                     | `jq`                        | `jq`               | `jq`               |
| yq             | 4.x (mikefarah)              | YAML on the command line. **apt's `yq` is a different tool** | `yq` (mikefarah)            | **bin**            | `yq` or bin        |

---

## Name gotchas

| Tool      | Where    | Problem                                                       | Fix                                                               |
| --------- | -------- | ------------------------------------------------------------- | ----------------------------------------------------------------- |
| bat       | Ubuntu   | Installs as `batcat`                                          | Use the release binary, or symlink `batcat` to `~/.local/bin/bat` |
| fd        | Ubuntu   | Installs as `fdfind`                                          | Use the release binary, or symlink `fdfind` to `~/.local/bin/fd`  |
| yq        | Ubuntu   | Python `yq` (different syntax)                                | Use the mikefarah release binary                                  |
| fd        | Fedora   | Package is `fd-find`                                          | Nothing; the binary is still `fd`                                 |
| flux      | Homebrew | Core formula `flux` is an unrelated scripting language        | `brew install fluxcd/tap/flux`                                    |
| kubelogin | Homebrew | Core formula `kubelogin` is int128's OIDC plugin, not Azure's | `brew install Azure/kubelogin/kubelogin`                          |
| terraform | Homebrew | No longer in Homebrew core                                    | `brew install hashicorp/tap/terraform`                            |
| azure-cli | Homebrew | Moved from a formula to a cask                                | `brew install --cask azure-cli`                                   |

> Symlinks (not aliases) matter for `bat` and `fd`: fzf previews and scripts run
> in a separate shell where aliases don't exist.

## Airgapped / restricted machines

These download from the internet at runtime and need to be pre-staged or mirrored:

- **Dotbot** (`./install` clones it from GitHub the first time)
- **starship and lazygit** (the playbook downloads GitHub release tarballs)
- **lazy.nvim plugins** (`~/.local/share/nvim/lazy/`) plus `lazy-lock.json`
- **Mason** LSP servers and formatters
- **Treesitter parsers**
- **Terraform providers** (`terraform init`; needs a provider mirror in `~/.terraformrc`)

## Package manager quick reference

| Task                      | macOS (brew)                | Ubuntu (apt)             | Fedora (dnf)                           |
| ------------------------- | --------------------------- | ------------------------ | -------------------------------------- |
| Refresh package lists     | `brew update`               | `sudo apt update`        | automatic (or `sudo dnf check-update`) |
| Install                   | `brew install <pkg>`        | `sudo apt install <pkg>` | `sudo dnf install <pkg>`               |
| Install a GUI app / font  | `brew install --cask <pkg>` | n/a                      | n/a                                    |
| Upgrade everything        | `brew upgrade`              | `sudo apt upgrade`       | `sudo dnf upgrade`                     |
| Search                    | `brew search <term>`        | `apt search <term>`      | `dnf search <term>`                    |
| Show package info         | `brew info <pkg>`           | `apt show <pkg>`         | `dnf info <pkg>`                       |
| List a package's files    | `brew list <pkg>`           | `dpkg -L <pkg>`          | `rpm -ql <pkg>`                        |
| Which package owns a file | `ls -l $(which <cmd>)`      | `dpkg -S <file>`         | `rpm -qf <file>`                       |
| Remove unused deps        | `brew autoremove`           | `sudo apt autoremove`    | `sudo dnf autoremove`                  |

## Check what's installed

```zsh
for t in git zsh python3 ansible curl nvim tree-sitter rg fd fzf zoxide eza bat \
         lazygit starship tmux kubectl kubelogin az terraform flux helm k9s jq yq; do
  if (( $+commands[$t] )); then
    printf '%-12s %s\n' "$t" "$($t --version 2>&1 | head -1)"
  else
    printf '%-12s MISSING\n' "$t"
  fi
done
```
