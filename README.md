# dotfiles

Debian-focused Zsh environment managed with [chezmoi](https://www.chezmoi.io/).

Stack: **Zsh** · **Antidote** · **Starship** · **fzf** · **eza** · **zoxide** · **bat** · **fd** · **ripgrep** · optional **mise**

Design notes and migration rationale: [docs/Modern Zsh Configuration 2026.md](docs/Modern%20Zsh%20Configuration%202026.md)

## Quick start

On a new Debian machine:

```bash
sh -c "$(curl -fsLS https://get.chezmoi.io/lb)" -- init --apply bgeneto
```

That installs chezmoi into `~/.local/bin`, clones this repo, prompts for a machine profile once, installs packages, deploys configs, and can set Zsh as your login shell.

Private clone (SSH):

```bash
sh -c "$(curl -fsLS https://get.chezmoi.io/lb)" -- \
  init --apply git@github.com:bgeneto/dotfiles.git
```

## Machine profiles

Chosen once on first `chezmoi init` and stored in `~/.config/chezmoi/chezmoi.toml`:

| Profile | Includes |
|---|---|
| `minimal` | Zsh, Git, fzf, Starship, eza, zoxide, bat, fd, ripgrep, Antidote, FiraCode Nerd Font |
| `server` | minimal + tmux, htop, rsync, ncdu |
| `workstation` | server + mise |

Change later by editing `profile` in `~/.config/chezmoi/chezmoi.toml`, then run `chezmoi apply`.

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
├── .chezmoi.toml.tmpl              # profile prompt + chezmoi config
├── .chezmoiexternal.toml           # Antidote external
├── .chezmoiscripts/                # idempotent bootstrap scripts
├── dot_zshenv                      → ~/.zshenv
└── dot_config/
    ├── zsh/                        → ~/.config/zsh/
    │   ├── dot_zshrc
    │   ├── plugins.txt
    │   └── conf.d/                 # aliases, completion, fzf, functions
    ├── starship.toml               → ~/.config/starship.toml
    └── mise/config.toml            → ~/.config/mise/config.toml
```

Host-specific settings (oneAPI, CUDA, proxies, etc.) go in unmanaged or managed files under:

```text
~/.config/zsh/conf.d/
```

## Requirements

- Debian (13 recommended; package set targets current Debian naming)
- `sudo` for apt package installation
- Network access for Antidote, FiraCode Nerd Font, and mise (workstation)

## License

[MIT](LICENSE)
