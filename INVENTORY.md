# Dotfiles Software Inventory

Everything these dotfiles expect to find on a machine. **Minimum** is the
oldest version known to work with this config; newer is fine (and preferred).

Install methods:

- **pkg**: system package manager (`apt` on Ubuntu, `dnf` on Fedora)
- **bin**: release tarball, binary placed in `~/.local/bin`
- Where Ubuntu's packaged version is often too old, prefer **bin** on Ubuntu.
  Fedora's packages are usually current enough.

---

## Base system (required)

| Tool              | Minimum | Why this minimum                                                     | Ubuntu (apt)      | Fedora (dnf)       |
| ----------------- | ------- | -------------------------------------------------------------------- | ----------------- | ------------------ |
| git               | 2.37    | `push.autoSetupRemote` (2.37), `merge.conflictstyle = zdiff3` (2.35) | `git`             | `git`              |
| zsh               | 5.8     | General config                                                       | `zsh`             | `zsh`              |
| stow              | 2.3     | `--no-folding`                                                       | `stow`            | `stow`             |
| curl              | any     | Downloads, API checks                                                | `curl`            | `curl`             |
| tar, gzip, unzip  | any     | Extracting tarballs; Neovim plugins need `unzip`                     | `tar gzip unzip`  | `tar gzip unzip`   |
| C compiler + make | any     | Treesitter compiles language parsers                                 | `build-essential` | `gcc gcc-c++ make` |

## Shell

| Tool                    | Minimum | Why this minimum                                    | Ubuntu                                | Fedora                        |
| ----------------------- | ------- | --------------------------------------------------- | ------------------------------------- | ----------------------------- |
| zsh-autosuggestions     | 0.7     | Sourced from `/usr/share/zsh-autosuggestions/`      | pkg `zsh-autosuggestions`             | pkg `zsh-autosuggestions`     |
| zsh-syntax-highlighting | 0.7     | Sourced from `/usr/share/zsh-syntax-highlighting/`  | pkg `zsh-syntax-highlighting`         | pkg `zsh-syntax-highlighting` |
| starship                | 1.20    | `[[kubernetes.contexts]]` syntax in `starship.toml` | **bin**                               | **bin** (not in Fedora repos) |
| fzf                     | 0.48    | `source <(fzf --zsh)`                               | **bin** (apt is usually too old)      | pkg `fzf`                     |
| zoxide                  | recent  | `zoxide init --cmd cd zsh`                          | pkg `zoxide` or bin                   | pkg `zoxide`                  |
| eza                     | any     | `ls` aliases (`--git`, `--group-directories-first`) | pkg `eza` (24.04+) or bin             | pkg `eza` or bin              |
| bat                     | any     | `cat` alias, fzf previews                           | **bin** (apt installs it as `batcat`) | pkg `bat`                     |
| tmux                    | 3.2     | Popup windows (3.2+)                                | pkg `tmux`                            | pkg `tmux`                    |

## Editor (Neovim / LazyVim)

| Tool            | Minimum | Why this minimum                                                            | Ubuntu                                | Fedora                           |
| --------------- | ------- | --------------------------------------------------------------------------- | ------------------------------------- | -------------------------------- |
| neovim          | 0.11.2  | Required by current LazyVim; `MANPAGER='nvim +Man!'`                        | **bin** (apt is too old)              | pkg `neovim`                     |
| tree-sitter CLI | 0.25    | Newer LazyVim (nvim-treesitter `main` branch) compiles parsers with it      | bin                                   | pkg `tree-sitter-cli` or bin     |
| ripgrep (`rg`)  | any     | LazyVim live grep                                                           | pkg `ripgrep`                         | pkg `ripgrep`                    |
| fd              | 8.0     | LazyVim file finder                                                         | **bin** (apt installs it as `fdfind`) | pkg `fd-find` (installs as `fd`) |
| lazygit         | 0.40    | `git` with no args, `<leader>gg` in LazyVim                                 | bin                                   | bin (or COPR)                    |
| Nerd Font       | v3      | Icons. Install on the machine running the **terminal**, not the remote host | n/a                                   | n/a                              |

## Kubernetes / cloud (work + homelab)

| Tool           | Minimum                      | Why this minimum                                             | Ubuntu             | Fedora             |
| -------------- | ---------------------------- | ------------------------------------------------------------ | ------------------ | ------------------ |
| kubectl        | cluster version ±1 minor     | Kubernetes version skew policy. Match each cluster           | bin                | bin                |
| kubelogin      | any                          | Only for AKS clusters with Entra ID login                    | bin                | bin                |
| az (Azure CLI) | recent                       | Login, Key Vault, AKS credentials                            | Microsoft apt repo | Microsoft dnf repo |
| terraform      | per repo                     | Check `required_version` in the repo's `.tf` files           | bin                | bin                |
| flux           | match cluster's Flux version | GitOps CLI                                                   | bin                | bin                |
| helm           | 3.x                          | Optional                                                     | bin                | pkg `helm` or bin  |
| k9s            | any                          | Optional TUI                                                 | bin                | bin                |
| jq             | 1.6                          | JSON on the command line                                     | pkg `jq`           | pkg `jq`           |
| yq             | 4.x (mikefarah)              | YAML on the command line. **apt's `yq` is a different tool** | **bin**            | pkg `yq` or bin    |

---

## Name gotchas

| Tool | Ubuntu installs it as          | Fix                                                                             |
| ---- | ------------------------------ | ------------------------------------------------------------------------------- |
| bat  | `batcat`                       | Use the release binary, or `alias bat=batcat` (fzf previews need the real name) |
| fd   | `fdfind`                       | Use the release binary, or symlink `fdfind` to `~/.local/bin/fd`                |
| yq   | Python `yq` (different syntax) | Use the mikefarah release binary                                                |

## Airgapped / restricted machines

These download from the internet at runtime and need to be pre-staged or mirrored:

- **lazy.nvim plugins** (`~/.local/share/nvim/lazy/`) plus `lazy-lock.json`
- **Mason** LSP servers and formatters
- **Treesitter parsers**
- **Terraform providers** (`terraform init`; needs a provider mirror in `~/.terraformrc`)

## apt vs dnf quick reference

| Task                      | Ubuntu (apt)             | Fedora (dnf)                           |
| ------------------------- | ------------------------ | -------------------------------------- |
| Refresh package lists     | `sudo apt update`        | automatic (or `sudo dnf check-update`) |
| Install                   | `sudo apt install <pkg>` | `sudo dnf install <pkg>`               |
| Upgrade everything        | `sudo apt upgrade`       | `sudo dnf upgrade`                     |
| Search                    | `apt search <term>`      | `dnf search <term>`                    |
| Show package info         | `apt show <pkg>`         | `dnf info <pkg>`                       |
| List a package's files    | `dpkg -L <pkg>`          | `rpm -ql <pkg>`                        |
| Which package owns a file | `dpkg -S <file>`         | `rpm -qf <file>`                       |

## Check what's installed

```zsh
for t in git zsh stow curl nvim tree-sitter rg fd fzf zoxide eza bat lazygit \
         starship tmux kubectl kubelogin az terraform flux helm k9s jq yq; do
  if (( $+commands[$t] )); then
    printf '%-12s %s\n' "$t" "$($t --version 2>&1 | head -1)"
  else
    printf '%-12s MISSING\n' "$t"
  fi
done
```
