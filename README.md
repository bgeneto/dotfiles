# dotfiles

Debian/WSL Zsh environment managed with [chezmoi](https://www.chezmoi.io/).

Stack: **Zsh** · **Antidote** · **Starship** · **fzf** / **fzf-tab** · **forgit** · **eza** · **zoxide** · **bat** · **fd** · **ripgrep** · **delta** · **mise**

Personal fork — PRs not accepted.

## Quick start

On your Debian (or WSL) machine:

```bash
sh -c "$(curl -fsLS https://get.chezmoi.io/lb)" -- init --apply bgeneto
```

That installs chezmoi into `~/.local/bin`, clones this repo, prompts for privilege mode, deploys configs, and bootstraps tools (mise, runtimes, fonts).

Private clone (SSH):

```bash
sh -c "$(curl -fsLS https://get.chezmoi.io/lb)" -- \
  init --apply git@github.com:bgeneto/dotfiles.git
```

After install, restart the terminal (or `exec zsh`) and select **FiraCode Nerd Font Mono** in your terminal emulator. On WSL, install the font on the Windows side too — see [Windows Terminal (WSL)](#windows-terminal-wsl).

## What you get (how to use it)

### Fuzzy finders (fzf)

| Shortcut | Action |
|---|---|
| `Ctrl+R` | Search command history |
| `Ctrl+T` | Insert file path (via `fd`, preview with `bat`/`eza`) |
| `Alt+C` | `cd` into a directory (via `fd`, tree preview) |

In fzf: type to filter, `Enter` to accept, `Ctrl+C` / `Esc` to cancel. Multi-term queries work (`^foo .go$`). Searches skip `.git`, `node_modules`, `.venv`, `dist`, `target`, and `.cache`.

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
| `bat FILE` | Syntax-highlighted file view (Catppuccin Mocha theme) |

`bat` is also the man-page renderer (`MANPAGER`); `less` remains the general `PAGER`.

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

When [delta](https://dandavison.github.io/delta/) is installed (the bootstrap ensures it), `GIT_PAGER=delta`, so normal `git diff` / `git log -p` use Catppuccin-themed coloration. See [Theme](#theme-catppuccin-mocha) to enable the palettes.

### Docker

Completions come from `docker completion zsh` when Docker is installed.

| Alias | Action |
|---|---|
| `dps` / `dpsa` | `docker ps` / `docker ps -a` |
| `dsp` | `docker system prune` |
| `dcb` | `compose build` (overrides iproute2 `dcb`) |
| `dcu` / `dcud` / `dcd` | `compose up` / `up -d` / `down` |
| `dcps` | `docker compose ps` |
| `dcl` / `dclf` | `compose logs` / `logs -f` |

### Privileges & services

| Shortcut / command | Action |
|---|---|
| `Esc` `Esc` | Prefix current / previous command with `sudo` |
| `sctl …` | `sudo systemctl …` |
| `uctl …` | `systemctl --user …` |
| `listen` | Show listening TCP/UDP ports |

### Archives

```bash
extract archive.tar.gz    # auto-picks tar/unzip/7z/etc.
```

### Project environments (mise)

direnv was removed in favour of mise, which also manages runtimes and virtualenvs. In a project, create a `mise.toml`:

```toml
[env]
NODE_ENV = "development"
_.file = ".env"         # load a dotenv file
_.path = "bin"          # prepend a directory to PATH

[tools]
node = "24"
```

For Python projects that use [uv](https://docs.astral.sh/uv/): run `uv sync` once to create `uv.lock` + `.venv`; mise then activates/deactivates the environment automatically as you enter and leave the directory (`python.uv_venv_auto = "source"`).

For older Python projects without `uv.lock`, declare the venv explicitly:

```toml
[tools]
python = "3.13"

[env]
_.python.venv = { path = ".venv", create = true }
```

Migrating an existing `.envrc`: translate `export FOO=bar` to `[env]` entries, `source_up`/`layout` calls to `_.source`/`_.path`/`_.python.venv`, then delete the `.envrc`.

### Prompt (Starship)

Two-line Catppuccin Mocha prompt: directory, git branch/status, Node and Python versions (plus active venv), command duration, exit status, and hostname over SSH. No extra keys — just look at the left prompt.

### Tool versions (mise)

[mise](https://mise.jdx.dev/) installs and activates runtimes and CLIs. It is activated in every interactive shell.

Global defaults come from this repo (`~/.config/mise/config.toml`): `node@24`, `python@3.13`, `uv@latest`, plus:

- discovery of `.nvmrc` / `.node-version` / `.python-version`
- automatic uv venv activation

**Pin tools for the current directory** (writes `mise.toml` in the project):

```bash
mise use node@24 python@3.13
mise use go@1.24
mise use rust@stable
mise use java@temurin-21
```

**Personal global overrides without fighting chezmoi.** `mise use --global` edits `~/.config/mise/config.toml`, which chezmoi manages — a later `chezmoi apply` would revert it. Use a separate `conf.d` file instead:

```bash
mise use --path "$XDG_CONFIG_HOME/mise/conf.d/dev-runtimes.toml" \
  node@24 python@3.13 go@1.24
```

The installer uses the same pattern for missing shell CLIs (`conf.d/shell-clis.toml`).

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

Config file: `~/.config/mise/config.toml` (from this repo). After editing it:

```bash
chezmoi apply && mise install
```

### Chezmoi maintenance

```bash
scripts/check.sh        # render templates + bash/zsh syntax + TOML/JSON checks
chezmoi update          # pull + apply
chezmoi apply           # apply local source changes
chezmoi diff            # preview pending changes
chezmoi edit ~/.zshenv  # edit a managed file
zplugins-update         # refresh Antidote plugins + rebuild bundle
```

### Local secrets

**Never put API keys or tokens in this repo.** Keep them in a mode-600 file that chezmoi does not manage:

```bash
install -m 600 /dev/null ~/.config/zsh/conf.d/99-secrets.zsh
cat >> ~/.config/zsh/conf.d/99-secrets.zsh <<'EOF'
export TAVILY_API_KEY="…"
EOF
```

`.zshrc` sources every `conf.d/*.zsh` (so the variables load automatically), and `~/.bashrc` sources the same file when present. `scripts/check.sh` scans for obvious secrets before you commit; when [semgrep](https://semgrep.dev/) is installed it additionally runs `scripts/semgrep-rules.yaml`, a generic secrets ruleset (API keys, tokens, private keys, connection strings). The migration script redacts secret-looking lines and chmods the migrated file to `600`. For a full audit: `semgrep scan --config p/secrets --config p/security-audit .`.

If a key was ever stored in a world-readable file, shell history, a backup, or a chat log, treat it as compromised and rotate it.

### Troubleshooting

```bash
dotfiles-doctor
```

Reports the active `ZDOTDIR`/`.zshrc`, resolved `node`/`npm`/`python`/`uv` paths, `mise current`, active `$VIRTUAL_ENV`, PATH duplicates, and warns when development commands resolve to `/mnt/c` or to leftover pyenv/nvm shims.

## Theme (Catppuccin Mocha)

Starship, fzf, bat, and delta all use the Catppuccin Mocha palette.

**bat** — the theme ships with this repo (`~/.config/bat/themes/Catppuccin Mocha.tmTheme`) and `BAT_THEME` is set automatically.

**delta** — delta reads its theme from git config. Add the vendored palettes and pick Mocha:

```bash
git config --global include.path "$PWD/docs/delta/catppuccin.gitconfig"
git config --global delta.features catppuccin-mocha
```

(Run from this repo, or adjust the path. Delta ≥ 0.19 + the vendored bat theme are enough.)

### Windows Terminal (WSL)

The Linux font install does not make the font available to Windows Terminal. On Windows:

1. Install **FiraCode Nerd Font** (download from the [nerd-fonts releases](https://github.com/ryanoasis/nerd-fonts/releases), select the `.ttf` files, right-click → *Install for all users*).
2. Copy the Catppuccin Mocha color scheme into Windows Terminal:

   ```bash
   scripts/install-windows-terminal-fragment.sh
   ```

   (or copy `docs/windows-terminal/catppuccin-mocha.json` manually to `%LOCALAPPDATA%\Microsoft\Windows Terminal\Fragments\dotfiles\`).

3. Restart Windows Terminal, then in *Settings → your WSL profile → Appearance* select **Catppuccin Mocha** as the color scheme and **FiraCode Nerd Font Mono** as the font face (optionally set both under *Defaults* to apply everywhere). Fragments cannot change `profiles.defaults`, so this last step is manual.

## Elevated vs userspace

This is a **userspace** dotfiles bootstrap: **sudo is never required** and never prompted for. The only first-run question is `elevated` (`true` / `false`). Default is `true` only when root or `sudo -n` already works; otherwise `false`.

| Step | Behavior |
|---|---|
| Host tools | Require `zsh`, `git`, and `curl`/`wget` already on PATH |
| Required CLIs | Prefer system `eza`, `starship`, `fzf`, `delta`, …; gaps via `mise use --path` → `~/.config/mise/conf.d/shell-clis.toml` + symlinks in `~/.local/bin` |
| Language runtimes | Always declared in mise config (`node@24`, `python@3.13`, `uv@latest`), installed on first apply |
| Non-required | Missing `tree` / `tmux` / `htop` / etc. are ignored (no auto-install) |
| `elevated=true` | Optional bonus: if passwordless sudo works, also `apt install` the package set (including `tmux`, `htop`, `rsync`, `ncdu`) + allow `chsh` |

| `elevated` | Meaning |
|---|---|
| `false` (typical) | Pure userspace: host tools + mise for missing required CLIs and runtimes |
| `true` | Same, plus optional passwordless apt/`chsh` when available |

Change later in `~/.config/chezmoi/chezmoi.toml`:

```toml
[data]
    elevated = false
```

Then run `chezmoi apply`.

## Upgrading from older revisions

- **Profiles are gone.** `minimal` / `server` / `workstation` were unified into one default profile. A leftover `profile = "…"` in `~/.config/chezmoi/chezmoi.toml` is ignored and can be deleted.
- **direnv was removed.** Remove `.envrc` files and move their contents into `mise.toml` (see [Project environments (mise)](#project-environments-mise)).
- **Secrets are never migrated.** The migration script redacts API keys/tokens and skips pyenv/nvm/cargo/bun blocks. Move any key found in `90-migrated-local.zsh`, a backup, or shell history into `~/.config/zsh/conf.d/99-secrets.zsh` (mode 600) and **rotate it** — exposure means it must be considered compromised.
- **Legacy runtime init:** if `~/.config/zsh/conf.d/90-migrated-local.zsh` still initializes pyenv, nvm, cargo, or bun, delete those blocks — mise now provides `node`, `python`, and `uv`. Keep only the Intel oneAPI / OpenBLAS blocks. Run `dotfiles-doctor` to confirm nothing resolves to `~/.pyenv` or `~/.nvm`.

## Migrating from zsh4humans

If this machine still has the [legacy gist / zsh4humans](https://gist.github.com/bgeneto/7b8a806b930350ff6a3ebd952f569415) setup, the first `chezmoi apply` runs a one-shot migrator that:

- copies/merges your existing history (`~/.zsh_history`) into `~/.local/state/zsh/history`
- backs up old `~/.zshrc`, `~/.zshenv`, p10k configs, and the z4h cache under `~/zsh-migration-backup/`
- extracts only the Intel oneAPI / OpenBLAS blocks into `~/.config/zsh/conf.d/90-migrated-local.zsh`

Runtime initializers (`pyenv`, `nvm`, `cargo`, `bun`) are **intentionally not migrated** — mise manages runtimes now. Review the backup if you need anything from those blocks.

Then restart the terminal (or `exec zsh`).

## Layout

```text
.
├── .chezmoi.toml.tmpl              # elevated prompt (single unified profile)
├── .chezmoiexternal.toml           # Antidote external
├── .chezmoiscripts/                # idempotent bootstrap scripts
├── dot_zshenv                      → ~/.zshenv
├── dot_config/
│   ├── zsh/                        → ~/.config/zsh/
│   │   ├── dot_zshrc
│   │   ├── plugins.txt
│   │   └── conf.d/                 # aliases, keys, fzf, git, pager, doctor, …
│   ├── starship.toml               → ~/.config/starship.toml (Catppuccin Mocha)
│   ├── mise/config.toml.tmpl       → ~/.config/mise/config.toml
│   └── bat/themes/                 → ~/.config/bat/themes/ (vendored theme)
├── docs/                           # reference material (not deployed)
│   ├── delta/                      # Catppuccin delta palettes
│   └── windows-terminal/           # Windows Terminal fragment
├── scripts/                        # local tooling (not deployed)
├── AGENTS.md                       # agent/contributor guide (not deployed)
└── README.md
```

Host-specific settings (oneAPI, CUDA, proxies, etc.) go under:

```text
~/.config/zsh/conf.d/
```

## Requirements

- Debian (13 recommended when using apt) or WSL2
- Network access for Antidote, FiraCode Nerd Font, and mise
- Userspace-first: **sudo is never required** (and never prompted for)
- Host must provide `zsh`, `git`, and `curl`/`wget`
- Required CLIs (`eza`, `starship`, `delta`, …): prefer system binaries; gaps via mise `conf.d/shell-clis.toml` + `~/.local/bin` symlinks
- **elevated=true:** optional passwordless apt + `chsh` when available

## License

[MIT](LICENSE)

Vendored themes come from [catppuccin/bat](https://github.com/catppuccin/bat), [catppuccin/delta](https://github.com/catppuccin/delta), and [catppuccin/windows-terminal](https://github.com/catppuccin/windows-terminal) (MIT).
