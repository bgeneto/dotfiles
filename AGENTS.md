# AGENTS.md

Guidance for AI coding agents (and humans) working on this repository.

## What this repo is

Chezmoi source for a userspace-first Debian/WSL Zsh environment.

- **One unified profile.** Every machine gets the full stack; there is no
  `minimal` / `server` / `workstation` selection and no `.profile` template
  branching. The only first-run prompt is `elevated`, and it only controls
  optional apt/`chsh` steps (passwordless sudo required).
- **Userspace-first.** Never make sudo mandatory. Optional apt steps run only
  when `elevated=true` and `sudo -n` already works.
- **mise manages runtimes** (node 24, python 3.13, uv). direnv was removed;
  project environments use mise `[env]` and `python.uv_venv_auto`.

## Never commit secrets

- No API keys, tokens, passwords, or credentials belong in this repository —
  not in configs, scripts, docs, commit messages, or test fixtures.
- Local secrets live only in `~/.config/zsh/conf.d/99-secrets.zsh` (mode 600,
  not managed by chezmoi) or in a password manager/keyring.
- The migration script redacts secret-looking lines and never copies
  pyenv/nvm/cargo/bun blocks. Do not weaken that filtering.
- `scripts/check.sh` fails on secret-like patterns and runs the
  `scripts/semgrep-rules.yaml` secrets ruleset when semgrep is installed. If a
  secret ever lands in the repo: remove it, rotate the key immediately, and
  rewrite history — deleting the line alone is not enough.

## Editing rules

- Edit files only in this repo. Never edit deployed copies under `~/.config`.
- Chezmoi naming conventions: `dot_` prefix, `.chezmoiscripts/run_*` scripts,
  `.tmpl` for templates. Keep `run_onchange_*` scripts idempotent.
- **Never** script or document `mise use --global`: it edits
  `~/.config/mise/config.toml`, which chezmoi manages. Use
  `mise use --path "$XDG_CONFIG_HOME/mise/conf.d/<name>.toml" …` instead.
- Keep `README.md` and this file in sync with behavior changes.
- `docs/**`, `scripts/**`, `README*`, `LICENSE*`, `AGENTS.md` are
  chezmoi-ignored (not deployed).

## Commands

```bash
scripts/check.sh                  # render templates + bash/zsh syntax + TOML/JSON + secrets
semgrep scan --config scripts/semgrep-rules.yaml .   # deeper secrets scan (optional)
chezmoi diff                      # preview pending changes
chezmoi apply                     # deploy
chezmoi execute-template --source . < file.tmpl   # render one template
mise current                      # active runtimes
dotfiles-doctor                   # diagnose PATH/runtime issues
```

## Layout

```text
.
├── .chezmoi.toml.tmpl            # elevated prompt (no profile prompt)
├── .chezmoiexternal.toml         # Antidote external
├── .chezmoiscripts/              # idempotent bootstrap scripts
├── dot_zshenv                    # ~/.zshenv (ZDOTDIR, PATH dedup)
├── dot_config/
│   ├── zsh/                      # .zshrc, plugins.txt, conf.d/*
│   ├── starship.toml             # Catppuccin Mocha prompt
│   ├── mise/config.toml.tmpl     # global runtimes + settings
│   └── bat/themes/               # vendored Catppuccin Mocha bat theme
├── docs/                         # reference docs (not deployed)
│   ├── delta/                    # Catppuccin delta gitconfig
│   └── windows-terminal/         # WT fragment
└── scripts/                      # local tooling (not deployed)
```

## Environment model

- mise activates early in `dot_config/zsh/dot_zshrc`.
- `.nvmrc` / `.node-version` / `.python-version` discovery is enabled via
  `idiomatic_version_file_enable_tools`.
- `python.uv_venv_auto = "source"` activates an existing uv venv when a
  project has a `uv.lock`.
- The legacy `90-migrated-local.zsh` file is not managed by chezmoi; it must
  not initialize pyenv/nvm (the migration script intentionally skips them).

## Before declaring success

Run `scripts/check.sh`, then `chezmoi diff` (and `chezmoi apply` when safe).
