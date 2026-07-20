# dotfiles

Debian-focused Zsh environment managed with [chezmoi](https://www.chezmoi.io/).

Stack: **Zsh** · **Antidote** · **Starship** · **fzf** / **fzf-tab** · **forgit** · **eza** · **zoxide** · **bat** · **fd** · **ripgrep** · **direnv** · **mise**

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

After install, restart the terminal (or `exec zsh`) and select **FiraCode Nerd Font Mono** in your terminal emulator.

## What you get (how to use it)

### Fuzzy finders (fzf)

| Shortcut | Action |
|---|---|
| `Ctrl+R` | Search command history |
| `Ctrl+T` | Insert file path (via `fd`, preview with `bat`/`eza`) |
| `Alt+C` | `cd` into a directory (via `fd`, tree preview) |

In fzf: type to filter, `Enter` to accept, `Ctrl+C` / `Esc` to cancel. Multi-term queries work (`^foo .go$`).

### Tab completion (fzf-tab)

| Shortcut | Action |
|---|---|
| `Tab` | Fuzzy completion menu instead of plain Zsh menu |
| `<` / `>` | Switch completion groups |

Works for commands, paths, git refs, Docker, etc.

### History & suggestions

| Shortcut / behavior | Action |
|---|---|
| `↑` / `↓` | History search matching what you already typed |
| Grey ghost text | Autosuggestion from history — accept with `→` or `End` |
| Leading space | Command is **not** saved to history (`HIST_IGNORE_SPACE`) |

Syntax highlighting colors valid/invalid commands as you type.

### Jump directories (zoxide)

Smarter `cd` that learns your habits:

```bash
z proj          # jump to highest-ranked match for "proj"
z foo bar       # match path containing both terms
zi              # interactive picker (fzf-style)
```

After a few normal `cd`s into a project, `z` will find it by a short fragment.

### Listing & files

| Command | Action |
|---|---|
| `ls` / `ll` / `la` / `lt` | `eza` listings (icons, dirs first; `lt` = tree) |
| `ff [pattern]` | Find files with `fd` |
| `fdir [pattern]` | Find directories with `fd` |
| `rg PATTERN` | Search file contents (ripgrep) |
| `bat FILE` | Syntax-highlighted file view (also used as `PAGER` / man pager) |

### Git (forgit + aliases)

Interactive (fzf-powered) — [forgit](https://github.com/wfxr/forgit):

| Alias | Action |
|---|---|
| `ga` | Interactive `git add` |
| `glo` | Interactive `git log` |
| `gd` | Interactive `git diff` |
| `gcf` | Interactive checkout file |
| `gcb` | Interactive checkout branch |
| `gbd` | Interactive delete branch |
| `gclean` | Interactive clean |
| `gss` | Interactive stash browser |
| `git forgit …` | Same tools as subcommands |

Fast non-interactive aliases:

| Alias | Action |
|---|---|
| `gst` | `git status -sb` |
| `gsw` | `git switch` |
| `gpr` | `git pull --rebase` |
| `gp` | `git push` |
| `gc` / `gcm` / `gca` | commit / commit -m / amend --no-edit |
| `gb` | `git branch` |

### Docker

OMZ Docker / Compose plugins add completions and helpers (e.g. `dps`-style aliases from the plugin). Also:

```bash
dsp    # docker system prune
```

### Privileges & services

| Shortcut / command | Action |
|---|---|
| `Esc` `Esc` | Prefix current / previous command with `sudo` |
| `sctl …` | `sudo systemctl …` |
| `uctl …` | `systemctl --user …` |
| `listen` | Show listening TCP/UDP ports |

### Archives

```bash
extract archive.tar.gz    # OMZ extract — auto-picks tar/unzip/etc.
```

### Project environments (direnv)

In a project directory:

```bash
echo 'export FOO=bar' > .envrc
direnv allow
```

Entering/leaving the directory loads/unloads `.envrc` automatically. Works with mise-managed tools.

### Prompt (Starship)

Shows directory, git branch/status, command duration, exit status, and hostname over SSH. No extra keys — just look at the left prompt.

### Tool versions (mise)

[mise](https://mise.jdx.dev/) installs and activates language runtimes and CLIs.
It is hooked in every interactive shell when present (workstation / userspace).

**Pin tools for the current directory** (writes `mise.toml`):

```bash
mise use node@24 python@3.13
mise use go@1.24
mise use rust@stable
mise use java@temurin-21
```

**Pin globally** (all shells / projects):

```bash
mise use --global node@24 python@3.13
mise use --global usage          # shell completions helper used by mise
```

**Install & inspect:**

```bash
mise install                     # install everything from mise.toml / config
mise install node@24             # one tool
mise ls                          # installed versions
mise ls-remote node              # available versions
mise current                     # active versions in this directory
mise which node                  # path to the resolved binary
mise upgrade                     # bump to newest matching versions
```

**Typical developer set:**

```bash
mise use --global \
  node@24 \
  python@3.13 \
  go@1.24 \
  ripgrep@latest \
  jq@latest
```

**With direnv** — in a project `.envrc`:

```bash
use mise
# or: eval "$(mise activate bash)"
```

Then `direnv allow`. Project tools from `mise.toml` load when you `cd` in.

Config file: `~/.config/mise/config.toml` (from this repo). After editing it:

```bash
chezmoi apply && mise install
```

### Chezmoi maintenance

```bash
chezmoi update          # pull + apply
chezmoi apply           # apply local source changes
chezmoi diff            # preview pending changes
chezmoi edit ~/.zshenv  # edit a managed file
zplugins-update         # refresh Antidote plugins + rebuild bundle
```

## Machine profile

Chosen once on first `chezmoi init` and stored in `~/.config/chezmoi/chezmoi.toml`.
Type the full value and press Enter (defaults are shown in brackets):

| Profile | Includes |
|---|---|
| `minimal` | Full Zsh stack above, Antidote, FiraCode Nerd Font |
| `server` | minimal + tmux, htop, rsync, ncdu (apt / elevated only) |
| `workstation` | server + mise language runtimes |

## Elevated vs userspace

Orthogonal to profile — also prompted once (`true` or `false`, then Enter). The default is `true` when you are root or in the `sudo`/`wheel`/`admin` group; otherwise `false`:

| `elevated` | Behavior |
|---|---|
| `true` | `sudo apt` installs packages; `chsh` sets login shell |
| `false` | no sudo/apt/chsh; shell CLIs installed with **mise** into your user prefix |

If `elevated=true` but this account cannot use sudo (not root, no passwordless sudo, not in an admin group), apt is skipped automatically and missing shell CLIs are installed with mise into `~/.local` instead.

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

## Migrating from zsh4humans

If this machine still has the [legacy gist / zsh4humans](https://gist.github.com/bgeneto/7b8a806b930350ff6a3ebd952f569415) setup, the first `chezmoi apply` runs a one-shot migrator that:

- copies/merges your existing history (`~/.zsh_history`) into `~/.local/state/zsh/history`
- backs up old `~/.zshrc`, `~/.zshenv`, p10k configs, and the z4h cache under `~/zsh-migration-backup/`
- optionally extracts intel/OpenBLAS/pyenv blocks into `~/.config/zsh/conf.d/90-migrated-local.zsh`

Then restart the terminal (or `exec zsh`).

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
    │   └── conf.d/                 # aliases, keys, fzf, git, pager, …
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
- **elevated=true:** `sudo` for apt when available; ability to run `chsh` (falls back to host tools if sudo is missing)
- **elevated=false:** preinstalled `zsh`, `git`, and `curl`/`wget`

## License

[MIT](LICENSE)
