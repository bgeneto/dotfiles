# dotfiles

Debian-focused Zsh environment managed with [chezmoi](https://www.chezmoi.io/).

Stack: **Zsh** · **Antidote** · **Starship** · **fzf** · **eza** · **zoxide** · **bat** · **fd** · **ripgrep** · **mise** (userspace / workstation)

## Quick start

On a new Debian machine:

```bash
sh -c "$(curl -fsLS https://get.chezmoi.io/lb)" -- init --apply bgeneto
```

That installs chezmoi into `~/.local/bin`, clones this repo, prompts for profile and privilege mode, deploys configs, and bootstraps tools.

Private clone (SSH):

```bash
sh -c "$(curl -fsLS https://get.chezmoi.io/lb)" -- \
  init --apply git@github.com:bgeneto/dotfiles.git
```

## Machine profile

Chosen once on first `chezmoi init` and stored in `~/.config/chezmoi/chezmoi.toml`:

| Profile | Includes |
|---|---|
| `minimal` | Zsh stack, Antidote, FiraCode Nerd Font |
| `server` | minimal + tmux, htop, rsync, ncdu (apt / elevated only) |
| `workstation` | server + mise language runtimes |

## Elevated vs userspace

Orthogonal to profile — also prompted once:

| `elevated` | Behavior |
|---|---|
| `true` (default) | `sudo apt` installs packages; `chsh` sets login shell |
| `false` | no sudo/apt/chsh; shell CLIs installed with **mise** into your user prefix |

Userspace mode still requires these to be preinstalled on the host:

- `zsh`
- `git`
- `curl` (or `wget`)

Server extras (`tmux`, `htop`, `rsync`, `ncdu`) are apt-only. Without elevation, install them yourself or omit them.

Change later in `~/.config/chezmoi/chezmoi.toml`:

```toml
[data]
    profile = "workstation"
    elevated = false
```

Then run `chezmoi apply`.

## Daily use

```bash
chezmoi update          # pull + apply
chezmoi apply           # apply local source changes
chezmoi diff            # preview pending changes
chezmoi edit ~/.zshenv  # edit a managed file
zplugins-update         # refresh Antidote plugins + rebuild bundle
```

## Layout

```text
.
├── .chezmoi.toml.tmpl              # profile + elevated prompts
├── .chezmoiexternal.toml           # Antidote external
├── .chezmoiscripts/                # idempotent bootstrap scripts
├── dot_zshenv                      → ~/.zshenv
└── dot_config/
    ├── zsh/                        → ~/.config/zsh/
    │   ├── dot_zshrc
    │   ├── plugins.txt
    │   └── conf.d/                 # aliases, completion, fzf, functions
    ├── starship.toml               → ~/.config/starship.toml
    └── mise/config.toml.tmpl       → ~/.config/mise/config.toml
```

Host-specific settings (oneAPI, CUDA, proxies, etc.) go under:

```text
~/.config/zsh/conf.d/
```

## Requirements

- Debian (13 recommended when using apt)
- Network access for Antidote, FiraCode Nerd Font, and mise
- **elevated=true:** `sudo` for apt; ability to run `chsh`
- **elevated=false:** preinstalled `zsh`, `git`, and `curl`/`wget`

## License

[MIT](LICENSE)
