# Modern Zsh Configuration 2026

## Prompt:
7/18/2026, 1:35:36 PM

I'm currently using zsh with zsh4humans for nice visuals, plugins and ready to use settings. what is a 2026 modern approach to configure zsh on debian so it behaves similiar to my setup describe here, with modern nerd fonts, eza, fzf search etc...:
https://gist.github.com/bgeneto/7b8a806b930350ff6a3ebd952f569415

## Response:
7/18/2026, 1:35:35 PM

I’ll inspect your gist first, then compare it against current 2026 Zsh tooling and propose a Debian setup that preserves the same ergonomics without unnecessary framework overhead.

Your gist maps cleanly to a modular replacement. I’ve also found a few items worth correcting during migration: `exa` is obsolete, the package-manager alias is not persisted reliably, and the shell-level `ulimit` changes should not live in `.zshrc`.

> **Buscou arquivo no GitHub a partir de URL**
>
> 
>
> **Pesquisando na web**
>
> [zsh install and config · GitHub](https://gist.github.com/bgeneto/7b8a806b930350ff6a3ebd952f569415)
>
> **Pesquisou na web e em várias plataformas GitHub e Gist**
>
> 
>
> **Analisando ferramentas para Debian**
>
> Estou considerando o uso de `mise` para gerenciar ferramentas modernas, mas ele traz sobrecarga. Alternativamente, pode-se usar `apt` para pacotes principais e instalar o `eza` de forma manual, pois não está no Debian 12.
>
> **Analisou ferramentas para Debian**
>
> 
>
> **Buscando informações sobre instalação de ferramentas modernas**
>
> [GitHub - ajeetdsouza/zoxide: A smarter cd command. Supports all major shells. · GitHub](https://github.com/ajeetdsouza/zoxide)
>
> **Pesquisou sobre instalação de ferramentas e pacotes no Debian**
>
> 
>
> **Verificou e gerenciou plugins do Docker e Antidote**
>
> 
>
> **Buscando informações sobre instalação de ferramentas com mise**
>
> [Releases · jdx/mise · GitHub](https://github.com/jdx/mise/releases)
> [Ubi Backend | mise-en-place](https://mise.jdx.dev/dev-tools/backends/ubi.html)
>
> **Buscou informações sobre instalação de ferramentas com mise**
>
> 
>
> Pensou por 5m 46s

## Recommended 2026 stack

For a new Debian configuration, I would **not replace zsh4humans with another monolithic shell distribution**. I would use:

- **Zsh 5.9** as the shell
- **Antidote** as a minimal, native Zsh plugin manager
- **Starship** as the prompt
- **fzf** for `Ctrl+R`, `Ctrl+T`, `Alt+C`
- **fzf-tab** for interactive Tab completion
- **eza**, **bat**, **fd**, **ripgrep**, and **zoxide**
- Selected Oh My Zsh plugins only: Docker, Compose, extract, and history

This is especially appropriate now because both zsh4humans and its bundled Powerlevel10k prompt explicitly describe themselves as receiving very limited maintenance. Antidote remains actively maintained and generates a static plugin bundle, while Starship provides an actively maintained, fast, Nerd-Font-aware prompt configured through one TOML file. ([GitHub](https://github.com/romkatv/zsh4humans))

Conceptually, the migration is:

```text
zsh4humans              → native Zsh configuration
z4h plugin management   → Antidote
Powerlevel10k            → Starship
z4h fuzzy completion     → fzf + fzf-tab
exa                      → eza
manual find functions    → fd
manual directory search  → zoxide
large .zshrc             → XDG config + conf.d modules
```

## 1. Install the tools

The cleanest target today is Debian 13. Debian 13 includes recent packaged versions of Zsh, fzf, eza, Starship, and zoxide; Debian 12 entered its LTS phase in July 2026. ([Debian](https://www.debian.org/releases/?utm_source=chatgpt.com))

```bash
sudo apt update

sudo apt install -y \
  zsh git curl wget unzip xz-utils fontconfig \
  eza fzf starship zoxide bat fd-find ripgrep \
  tree jq lsof pigz
```

Create conventional command names for Debian’s `batcat` and `fdfind`, where necessary:

```bash
mkdir -p ~/.local/bin

command -v bat >/dev/null || {
  batcat_path="$(command -v batcat)" &&
    ln -sf "$batcat_path" ~/.local/bin/bat
}

command -v fd >/dev/null || {
  fdfind_path="$(command -v fdfind)" &&
    ln -sf "$fdfind_path" ~/.local/bin/fd
}
```

Debian deliberately packages the `fd` executable as `fdfind`; the user-level symlink is the conventional workaround. Older Debian releases similarly use `batcat` for `bat`. ([GitHub](https://github.com/sharkdp/fd?utm_source=chatgpt.com))

Install Antidote:

```bash
mkdir -p ~/.local/share

git clone --depth=1 \
  https://github.com/mattmc3/antidote.git \
  ~/.local/share/antidote
```

Create the configuration directories:

```bash
mkdir -p \
  ~/.config/zsh/conf.d \
  ~/.cache/zsh \
  ~/.local/state/zsh
```

## 2. Use the XDG directory layout

Keep only `~/.zshenv` in your home directory.

### `~/.zshenv`

```zsh
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
export PATH="$HOME/.local/bin:$PATH"
```

This gives you:

```text
~/.zshenv
~/.config/zsh/.zshrc
~/.config/zsh/plugins.txt
~/.config/zsh/conf.d/*.zsh
~/.config/starship.toml
~/.local/state/zsh/history
~/.cache/zsh/
```

## 3. Define the plugins

### `~/.config/zsh/plugins.txt`

```text
# Compatibility helpers needed by selected Oh My Zsh plugins.
getantidote/use-omz

# Only the Oh My Zsh plugins actually used.
ohmyzsh/ohmyzsh path:plugins/docker
ohmyzsh/ohmyzsh path:plugins/docker-compose
ohmyzsh/ohmyzsh path:plugins/extract
ohmyzsh/ohmyzsh path:plugins/history

# Fuzzy regular Tab completion.
Aloxaf/fzf-tab

# Interactive enhancements.
zsh-users/zsh-history-substring-search
zsh-users/zsh-autosuggestions

# Keep highlighting last because it wraps the ZLE widgets.
zdharma-continuum/fast-syntax-highlighting
```

Antidote supports loading individual directories from large repositories such as Oh My Zsh, so you do not have to initialize the entire framework. ([GitHub](https://github.com/mattmc3/antidote))

Keeping the Docker plugins from your gist is still reasonable. The current Compose plugin automatically selects modern `docker compose` when the legacy `docker-compose` executable is unavailable. 

## 4. Main Zsh configuration

### `~/.config/zsh/.zshrc`

```zsh
# ---------------------------------------------------------------------------
# Basic environment
# ---------------------------------------------------------------------------

mkdir -p "$XDG_CACHE_HOME/zsh" "$XDG_STATE_HOME/zsh"

export EDITOR="${EDITOR:-vim}"
export VISUAL="${VISUAL:-$EDITOR}"

# ---------------------------------------------------------------------------
# History
# ---------------------------------------------------------------------------

HISTFILE="$XDG_STATE_HOME/zsh/history"
HISTSIZE=100000
SAVEHIST=100000

setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_REDUCE_BLANKS

# ---------------------------------------------------------------------------
# General shell behavior
# ---------------------------------------------------------------------------

setopt AUTO_CD
setopt GLOB_DOTS
setopt NO_NOMATCH
setopt INTERACTIVE_COMMENTS

# ---------------------------------------------------------------------------
# Native Zsh completion
# Must run before fzf-tab is loaded.
# ---------------------------------------------------------------------------

autoload -Uz compinit

# -C skips the full security check when a current dump exists.
compinit -C -d "$XDG_CACHE_HOME/zsh/zcompdump"

zstyle ':completion:*' menu no
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '[%d]'

# Case-insensitive completion followed by partial-word matching.
zstyle ':completion:*' matcher-list \
  'm:{a-zA-Z}={A-Za-z}' \
  'r:|[._-]=* r:|=*'

if (( $+commands[dircolors] )); then
  eval "$(dircolors -b)"
  zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
fi

# ---------------------------------------------------------------------------
# fzf
#
# Ctrl+R: history
# Ctrl+T: files
# Alt+C: directories
# ---------------------------------------------------------------------------

if (( $+commands[fzf] )); then
  export FZF_DEFAULT_OPTS="
    --height=60%
    --layout=reverse
    --border
    --info=inline
  "

  export FZF_CTRL_T_OPTS="
    --walker-skip .git,node_modules,target,dist,.cache
    --preview '
      bat --color=always --style=numbers --line-range=:500 {} 2>/dev/null ||
      eza --tree --level=2 --color=always --icons=always {}
    '
  "

  export FZF_ALT_C_OPTS="
    --walker-skip .git,node_modules,target,dist,.cache
    --preview '
      eza --tree --level=2 --color=always --icons=always {}
    '
  "

  source <(fzf --zsh)
fi

# ---------------------------------------------------------------------------
# Antidote static plugin bundle
# ---------------------------------------------------------------------------

typeset -g ANTIDOTE_HOME="$XDG_DATA_HOME/antidote"
typeset -g ZSH_PLUGINS_FILE="$ZDOTDIR/plugins.txt"
typeset -g ZSH_PLUGINS_BUNDLE="$XDG_CACHE_HOME/zsh/plugins.zsh"

if [[ -r "$ANTIDOTE_HOME/antidote.zsh" ]]; then
  if [[ ! -r "$ZSH_PLUGINS_BUNDLE" ||
        "$ZSH_PLUGINS_FILE" -nt "$ZSH_PLUGINS_BUNDLE" ]]; then
    source "$ANTIDOTE_HOME/antidote.zsh"
    antidote bundle < "$ZSH_PLUGINS_FILE" >| "$ZSH_PLUGINS_BUNDLE"
  fi

  source "$ZSH_PLUGINS_BUNDLE"
else
  print -u2 "Antidote not found at $ANTIDOTE_HOME"
fi

# ---------------------------------------------------------------------------
# fzf-tab
# ---------------------------------------------------------------------------

zstyle ':fzf-tab:*' switch-group '<' '>'

zstyle ':fzf-tab:complete:cd:*' fzf-preview \
  'eza --tree --level=2 --color=always --icons=always -- "$realpath"'

# ---------------------------------------------------------------------------
# Key bindings
# ---------------------------------------------------------------------------

bindkey -e

# Prefix-aware history search using the up/down arrows.
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# Alternative terminal escape sequences.
bindkey '^[OA' history-substring-search-up
bindkey '^[OB' history-substring-search-down

# ---------------------------------------------------------------------------
# Modern command aliases
# ---------------------------------------------------------------------------

alias ls='eza --icons=auto --group-directories-first'
alias ll='eza -lbF --icons=auto --group-directories-first'

alias la='eza \
  -lbhHigmuSa \
  --icons=auto \
  --group-directories-first \
  --time-style=long-iso \
  --color-scale=all'

alias lt='eza \
  --tree \
  --level=2 \
  --icons=auto \
  --group-directories-first'

alias free='free -h'
alias df='df -hT'

alias update='sudo apt update'
alias upgrade='sudo apt update && sudo apt full-upgrade'
alias inst='sudo apt install'
alias remove='sudo apt remove'
alias search='apt search'

alias listen='sudo lsof -i -P -n | grep LISTEN'
alias dsp='docker system prune'

# ---------------------------------------------------------------------------
# Functions
# ---------------------------------------------------------------------------

mkdcd() {
  (( $# == 1 )) || {
    print -u2 'Usage: mkdcd DIRECTORY'
    return 2
  }

  mkdir -p -- "$1" && builtin cd -P -- "$1"
}

# Search regular files. An empty argument lists all files.
ff() {
  fd \
    --type f \
    --hidden \
    --exclude .git \
    -- "${1:-}" .
}

# Search directories without conflicting with the `fd` executable.
fdir() {
  fd \
    --type d \
    --hidden \
    --exclude .git \
    -- "${1:-}" .
}

# Less collision-prone systemd wrappers.
sctl() {
  sudo systemctl "$@"
}

uctl() {
  systemctl --user "$@"
}

# Rebuild the static bundle after plugin updates.
zplugins-update() {
  source "$ANTIDOTE_HOME/antidote.zsh" || return

  antidote update || return
  antidote bundle < "$ZSH_PLUGINS_FILE" >| "$ZSH_PLUGINS_BUNDLE"

  exec zsh
}

# ---------------------------------------------------------------------------
# Host-specific configuration
#
# Put Intel oneAPI, OpenBLAS, CUDA, proxy or work-machine settings in:
# ~/.config/zsh/conf.d/*.zsh
# ---------------------------------------------------------------------------

for rc_file in "$ZDOTDIR"/conf.d/*.zsh(N); do
  source "$rc_file"
done

# ---------------------------------------------------------------------------
# Navigation and prompt
# ---------------------------------------------------------------------------

eval "$(zoxide init zsh)"
eval "$(starship init zsh)"
```

Recent fzf versions provide the unified `fzf --zsh` integration for `Ctrl+R`, `Ctrl+T`, `Alt+C`, and fuzzy completion. `fzf-tab` then enhances normal Zsh completion while retaining the underlying completion system and must be loaded after `compinit`. ([GitHub](https://github.com/junegunn/fzf))

## 5. Configure Starship

A simple configuration preserving the clean z4h/Powerlevel10k character:

### `~/.config/starship.toml`

```toml
"$schema" = "https://starship.rs/config-schema.json"

add_newline = false
scan_timeout = 30
command_timeout = 500

[character]
success_symbol = "[❯](bold green)"
error_symbol = "[❯](bold red)"
vimcmd_symbol = "[❮](bold green)"
vimcmd_replace_one_symbol = "[❮](bold purple)"
vimcmd_replace_symbol = "[❮](bold purple)"
vimcmd_visual_symbol = "[❮](bold yellow)"

[directory]
style = "bold cyan"
truncation_length = 4
truncate_to_repo = false
read_only = " 󰌾"

[git_branch]
symbol = " "

[git_status]
style = "bold yellow"

[hostname]
ssh_only = true
format = "[$hostname]($style) "

[cmd_duration]
min_time = 1000
format = "took [$duration]($style) "

[status]
disabled = false
symbol = "✘"
```

Alternatively, Starship includes an official Nerd Font preset:

```bash
starship preset nerd-font-symbols \
  -o ~/.config/starship.toml
```

Starship uses `~/.config/starship.toml`, and the official Nerd Font preset supplies appropriate symbols for modules such as Git, Docker, Node.js, Python, and Rust. ([Starship](https://starship.rs/config/))

## 6. Install a Nerd Font correctly

I would use **JetBrainsMono Nerd Font Mono** for terminal work:

```bash
mkdir -p ~/.local/share/fonts/JetBrainsMonoNerdFont

curl -fsSL \
  https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz |
  tar -xJ -C ~/.local/share/fonts/JetBrainsMonoNerdFont

fc-cache -f
```

Then select this font in your terminal emulator:

```text
JetBrainsMono Nerd Font Mono
```

Nerd Fonts officially publishes per-family release archives and recommends the user font directory under `~/.local/share/fonts` on Linux. ([GitHub](https://github.com/ryanoasis/nerd-fonts?utm_source=chatgpt.com))

A crucial SSH distinction:

- When using a local Linux terminal, install the font locally.
- When using Windows Terminal, WezTerm, Kitty, Ghostty, VS Code, or another SSH client, install and select the Nerd Font on the **client machine**.
- Installing fonts on a headless Debian server does not change how your local terminal renders glyphs.

## 7. Changes I would make relative to your gist

Your current gist is functional, but I would explicitly correct these parts:

### Replace `exa`

```zsh
alias ll='exa ...'
```

becomes:

```zsh
alias ll='eza ...'
```

`eza` is the maintained successor with icons, Git metadata, tree rendering, hyperlinks, and configurable themes. ([GitHub](https://github.com/eza-community/eza))

### Do not define a function named `fd`

Your gist has a directory-search function called `fd()`. That shadows the modern `fd` executable.

Use:

```zsh
fdir() {
  fd --type d --hidden --exclude .git -- "${1:-}" .
}
```

### Avoid generic functions named `start`, `stop`, and `status`

These names are likely to collide with project scripts, CLI programs, package commands, and shell functions.

Prefer:

```bash
sctl start docker
sctl status ssh
sctl restart caddy
```

or simply use `systemctl` directly.

### Remove `ulimit` from `.zshrc`

These lines from the gist:

```zsh
ulimit -s unlimited
ulimit -n 65536
```

modify every interactive shell but do not reliably configure systemd services, Docker containers, IDE terminals, or login-session policy.

For user sessions, use something such as:

```text
/etc/security/limits.d/90-local.conf
```

For systemd services, use:

```ini
[Service]
LimitNOFILE=65536
```

in a service override.

### Do not derive persistent aliases from an installer-local variable

Your installer determines `pkgmngt`, but the generated alias later depends on that variable:

```zsh
alias update="sudo $pkgmngt update"
```

Because your target is specifically Debian, explicit `apt` aliases are clearer and deterministic.

### Do not automatically create or start an RSA-specific SSH agent

This assumption is too narrow:

```zsh
ssh-add ~/.ssh/id_rsa
```

Modern installations may use:

```text
id_ed25519
hardware-backed FIDO2 keys
1Password SSH agent
GNOME Keyring
KDE Wallet
systemd-managed agents
Windows OpenSSH agent
```

The shell should normally reuse an existing agent rather than start a second one on every machine.

### Move machine-specific libraries out of the main file

Your Intel oneAPI, MKL, OpenBLAS, and Python runtime configuration should be separate:

```text
~/.config/zsh/conf.d/10-oneapi.zsh
~/.config/zsh/conf.d/20-openblas.zsh
~/.config/zsh/conf.d/30-python.zsh
```

For language-runtime management, `mise` is also a modern replacement for shell code that downloads and initializes pyenv manually. It supports activating development tools and environment configuration from a single Zsh hook. ([GitHub](https://github.com/jdx/mise?utm_source=chatgpt.com))

## Bottom line

The strongest 2026 setup for your use case is:

```text
Zsh
  + Antidote
  + Starship
  + fzf
  + fzf-tab
  + zsh-autosuggestions
  + fast-syntax-highlighting
  + history-substring-search
  + eza
  + fd
  + bat
  + ripgrep
  + zoxide
```

It will feel very similar to zsh4humans, but it is easier to audit, faster to diagnose, independent of a single distribution, and every major subsystem can be replaced without rebuilding the entire shell configuration.

---

**Sources:**

- [GitHub - romkatv/zsh4humans: A turnkey configuration for Zsh · GitHub](https://github.com/romkatv/zsh4humans)
- [Debian -- Debian Releases](https://www.debian.org/releases/?utm_source=chatgpt.com)
- [Configuration | Starship](https://starship.rs/config/)

## Prompt:
7/18/2026, 4:27:09 PM

wow ... your new recipe is great but it is a lot of manual work to do on every machine/PC and workstation I use (dozens). is there any modern way to automatize it so I can setup all that stuff with a single line command?

## Response:
7/18/2026, 4:27:10 PM

Yes. The modern pattern is to treat your shell setup as a versioned **dotfiles repository with an idempotent bootstrap**, so every machine converges from one command instead of repeating manual steps.

For your case, I would use **chezmoi as the entry point** and let it install packages, deploy files, choose workstation/server profiles, install Antidote, and set Zsh. Ansible becomes optional only when you also want centralized OS/service management.

> **Buscando documentação oficial sobre instalação e templates**
>
> [ansible-pull — Ansible Core Documentation](https://docs.ansible.com/projects/ansible-core/devel/cli/ansible-pull.html)
> [Quick start - chezmoi](https://www.chezmoi.io/quick-start/)
>
> **Buscou documentação oficial sobre instalação, templates e scripts**
>
> 
>
> **Recomendando configuração**
>
> Estou considerando o uso do chezmoi para ambientes de desenvolvimento simples ou combinado com Ansible se for necessário provisionamento completo. Podemos usar scripts e repositórios Git híbridos para gerenciar configurações e pacotes.
>
> **Recomendou configuração**
>
> 
>
> **Buscando documentação oficial para scripts run_onchange**
>
> [Use scripts to perform actions - chezmoi](https://www.chezmoi.io/user-guide/use-scripts-to-perform-actions/)
>
> **Buscou documentação e implantou automação com Chezmoi**
>
> 
>
> Pensou por 1m 34s

Yes. **chezmoi is almost exactly designed for this use case**: one Git repository containing your desired dotfiles, templates, package-install scripts, external plugins, and machine-specific profiles. It can install itself and apply the entire configuration on a new machine with one command. ([Chez Moi](https://www.chezmoi.io/install/?utm_source=chatgpt.com))

## The command you would run on every new machine

Assuming you create:

```text
https://github.com/bgeneto/dotfiles
```

the bootstrap becomes:

```bash
sh -c "$(curl -fsLS https://get.chezmoi.io/lb)" -- init --apply bgeneto
```

The `/lb` variant installs `chezmoi` into:

```text
~/.local/bin
```

so chezmoi itself does not require root access. Your package-installation script may still invoke `sudo` once to install Zsh and system packages. ([Chez Moi](https://www.chezmoi.io/install/?utm_source=chatgpt.com))

For a differently named repository:

```bash
sh -c "$(curl -fsLS https://get.chezmoi.io/lb)" -- \
  init --apply https://github.com/bgeneto/my-dotfiles.git
```

For a private repository:

```bash
sh -c "$(curl -fsLS https://get.chezmoi.io/lb)" -- \
  init --apply git@github.com:bgeneto/dotfiles.git
```

The private-repository form requires working GitHub SSH authentication on the new machine. For ease of provisioning, I would keep the non-secret shell configuration public and retrieve secrets separately from a password manager or encrypted chezmoi files.

Afterward, updating any machine is just:

```bash
chezmoi update
```

That pulls the repository and applies the new desired state. ([Chez Moi](https://www.chezmoi.io/user-guide/daily-operations/?utm_source=chatgpt.com))

---

# Recommended architecture

I would organize the setup into three layers:

```text
chezmoi
├── system bootstrap
│   ├── apt packages
│   ├── default shell
│   └── required directories
├── user environment
│   ├── Zsh configuration
│   ├── Starship
│   ├── Antidote
│   ├── fzf
│   ├── eza
│   └── zoxide
└── machine profiles
    ├── minimal
    ├── server
    └── workstation
```

The important point is that the scripts must be **idempotent**: running the installer several times should leave the machine in the same correct state rather than duplicating configuration.

chezmoi supports scripts that run every time, once, or only when their rendered content changes. In particular, `run_onchange_` scripts are ideal for package lists: add a package to the script, run `chezmoi update`, and only then will the installation script run again. ([Chez Moi](https://www.chezmoi.io/user-guide/use-scripts-to-perform-actions/?utm_source=chatgpt.com))

## Repository structure

```text
dotfiles/
├── .chezmoi.toml.tmpl
├── .chezmoiignore
├── .chezmoiexternal.toml
├── .chezmoiscripts/
│   ├── run_onchange_before_10-install-packages.sh.tmpl
│   ├── run_onchange_after_20-build-zsh-plugins.sh.tmpl
│   └── run_once_after_90-set-default-shell.sh.tmpl
├── dot_zshenv
└── dot_config/
    ├── zsh/
    │   ├── dot_zshrc
    │   ├── plugins.txt
    │   └── conf.d/
    │       ├── aliases.zsh
    │       ├── completion.zsh
    │       ├── fzf.zsh
    │       └── functions.zsh
    ├── starship.toml
    └── mise/
        └── config.toml
```

chezmoi translates names such as:

```text
dot_zshenv                 → ~/.zshenv
dot_config/zsh/dot_zshrc   → ~/.config/zsh/.zshrc
dot_config/starship.toml   → ~/.config/starship.toml
```

---

# Machine profiles

On first installation, chezmoi can ask what kind of machine it is.

## `.chezmoi.toml.tmpl`

```toml
{{- $profiles := list "minimal" "server" "workstation" -}}
{{- $profile := promptChoiceOnce . "profile" "Machine profile" $profiles "workstation" -}}

[data]
profile = {{ $profile | quote }}

[diff]
exclude = ["scripts"]

[status]
exclude = ["scripts"]
```

The bootstrap would ask once:

```text
Machine profile:
  minimal
  server
  workstation
```

The selected value is retained in that machine’s local chezmoi configuration. Templates can then generate different files or package lists for different machines. This is a native chezmoi use case. ([Chez Moi](https://www.chezmoi.io/reference/templates/init-functions/promptChoiceOnce/?utm_source=chatgpt.com))

A sensible interpretation would be:

| Profile | Installed |
|---|---|
| `minimal` | Zsh, Git, fzf, Starship, basic aliases |
| `server` | Minimal plus Docker helpers, tmux, diagnostics |
| `workstation` | Server tools plus Nerd Font, desktop integrations and development utilities |

---

# Automated Debian package installation

## `.chezmoiscripts/run_onchange_before_10-install-packages.sh.tmpl`

```bash
#!/usr/bin/env bash
set -euo pipefail

if [[ "$(uname -s)" != "Linux" ]] || [[ ! -f /etc/debian_version ]]; then
    exit 0
fi

if [[ "$EUID" -eq 0 ]]; then
    SUDO=()
else
    SUDO=(sudo)
fi

packages=(
    zsh
    git
    curl
    ca-certificates
    unzip
    xz-utils
    fontconfig
    fzf
    bat
    fd-find
    ripgrep
    tree
    jq
    lsof
    pigz
)

{{- if eq .profile "server" }}
packages+=(
    tmux
    htop
    rsync
    ncdu
)
{{- end }}

{{- if eq .profile "workstation" }}
packages+=(
    tmux
    htop
    rsync
    ncdu
)
{{- end }}

"${SUDO[@]}" apt-get update
DEBIAN_FRONTEND=noninteractive \
    "${SUDO[@]}" apt-get install -y "${packages[@]}"

mkdir -p "$HOME/.local/bin"

if command -v batcat >/dev/null 2>&1 &&
   ! command -v bat >/dev/null 2>&1; then
    ln -sfn "$(command -v batcat)" "$HOME/.local/bin/bat"
fi

if command -v fdfind >/dev/null 2>&1 &&
   ! command -v fd >/dev/null 2>&1; then
    ln -sfn "$(command -v fdfind)" "$HOME/.local/bin/fd"
fi
```

Because this is a `run_onchange_` script, chezmoi records its rendered content. If you later add another package, the content changes and the script runs again. If nothing changes, it is skipped. ([Chez Moi](https://www.chezmoi.io/user-guide/use-scripts-to-perform-actions/?utm_source=chatgpt.com))

---

# Let chezmoi install Antidote

Instead of manually running `git clone`, use a chezmoi external.

## `.chezmoiexternal.toml`

```toml
[".local/share/antidote"]
type = "git-repo"
url = "https://github.com/mattmc3/antidote.git"
refreshPeriod = "168h"
clone.args = ["--depth=1"]
```

When the directory is absent, chezmoi clones it. When refreshed, it can pull updates. External resources support files, archives, individual archive members, and Git repositories. ([Chez Moi](https://www.chezmoi.io/reference/special-files/chezmoiexternal-format/?utm_source=chatgpt.com))

You can use the same mechanism for other repositories, but I would avoid managing every command this way. Keep it primarily for Antidote and similar shell components.

---

# Automatically rebuild the Antidote bundle

## `.chezmoiscripts/run_onchange_after_20-build-zsh-plugins.sh.tmpl`

```bash
#!/usr/bin/env bash
set -euo pipefail

ANTIDOTE_HOME="$HOME/.local/share/antidote"
PLUGIN_FILE="$HOME/.config/zsh/plugins.txt"
CACHE_DIR="$HOME/.cache/zsh"
BUNDLE_FILE="$CACHE_DIR/plugins.zsh"

# Plugin configuration checksum:
# {{ include "dot_config/zsh/plugins.txt" | sha256sum }}

mkdir -p "$CACHE_DIR"

if [[ ! -r "$ANTIDOTE_HOME/antidote.zsh" ]]; then
    printf 'Antidote not found: %s\n' "$ANTIDOTE_HOME" >&2
    exit 1
fi

if [[ ! -r "$PLUGIN_FILE" ]]; then
    printf 'Plugin file not found: %s\n' "$PLUGIN_FILE" >&2
    exit 1
fi

zsh -c "
    source '$ANTIDOTE_HOME/antidote.zsh'
    antidote bundle < '$PLUGIN_FILE' >| '$BUNDLE_FILE'
"
```

The checksum comment causes the rendered script to change when `plugins.txt` changes, which makes chezmoi rerun it. This is the documented pattern for connecting a `run_onchange_` script to another managed file. ([Chez Moi](https://www.chezmoi.io/user-guide/use-scripts-to-perform-actions/?utm_source=chatgpt.com))

---

# Automatically make Zsh the default shell

## `.chezmoiscripts/run_once_after_90-set-default-shell.sh.tmpl`

```bash
#!/usr/bin/env bash
set -euo pipefail

zsh_path="$(command -v zsh)"

if [[ -z "$zsh_path" ]]; then
    echo "zsh is not installed" >&2
    exit 1
fi

current_shell="$(getent passwd "$USER" | cut -d: -f7)"

if [[ "$current_shell" == "$zsh_path" ]]; then
    exit 0
fi

echo
echo "Changing the default shell to: $zsh_path"
chsh -s "$zsh_path"
```

This may ask for the user’s password, depending on the machine’s PAM and `chsh` configuration. That is desirable: I would not weaken the system merely to eliminate one legitimate authentication prompt.

On managed systems where you have passwordless administrative provisioning, it could instead use:

```bash
sudo usermod --shell "$zsh_path" "$USER"
```

---

# Add `mise` for development runtimes

For someone using dozens of development machines, I would also add **mise**:

```text
chezmoi → dotfiles and workstation bootstrap
mise    → Node, Python, Go, Rust, Java and project-specific CLI versions
```

This prevents your shell repository from accumulating custom installers for every language runtime.

mise uses version-controlled TOML configuration and can install globally selected tools as well as project-specific versions. Its GitHub backend can also install release binaries directly. ([mise-en-place](https://mise.jdx.dev/getting-started?utm_source=chatgpt.com))

chezmoi could install mise using a bootstrap script:

```bash
#!/usr/bin/env bash
set -euo pipefail

if ! command -v mise >/dev/null 2>&1; then
    curl -fsSL https://mise.run | sh
fi

"$HOME/.local/bin/mise" install
```

Then your `.zshrc` would contain:

```zsh
if [[ -x "$HOME/.local/bin/mise" ]]; then
  eval "$("$HOME/.local/bin/mise" activate zsh)"
fi
```

Put this near the end of `.zshrc`, because mise’s documentation recommends activation after other `PATH` modifications. ([mise-en-place](https://mise.jdx.dev/getting-started?utm_source=chatgpt.com))

---

# Nerd Font handling

Fonts need profile-aware treatment.

For a desktop or laptop:

```text
workstation → install JetBrainsMono Nerd Font locally
```

For an SSH server:

```text
server → do not install fonts
```

The font that renders the terminal is normally located on the **terminal client**, not on the SSH server. Therefore:

- SSH from Windows Terminal: install the font on Windows.
- SSH from your Debian workstation: install the font on that workstation.
- A headless server does not need the Nerd Font package.

Your `workstation` profile can automate installation under:

```text
~/.local/share/fonts/JetBrainsMonoNerdFont/
```

but Windows terminals would still need their own corresponding Windows setup.

---

# For all machines at once: add Ansible

chezmoi solves:

```text
“Log into a new machine and configure my environment with one command.”
```

When you want:

```text
“Configure 30 SSH-accessible Debian machines from one control machine.”
```

use Ansible to invoke the bootstrap remotely.

Ansible is agentless, operates over SSH, and is designed around declarative, repeatable configuration. Its `ansible-pull` mode can also let each machine retrieve configuration from Git and apply it locally. ([Ansible](https://docs.ansible.com/projects/ansible-core/devel/cli/ansible-pull.html?utm_source=chatgpt.com))

A minimal Ansible task could execute the chezmoi installer for your user:

```yaml
- name: Configure user shell with chezmoi
  ansible.builtin.shell: >
    sh -c "$(curl -fsLS https://get.chezmoi.io/lb)"
    -- init --apply bgeneto
  args:
    executable: /bin/bash
    creates: "{{ ansible_env.HOME }}/.local/share/chezmoi"
```

That gives you two provisioning modes:

```text
Individual machine:
sh -c "$(curl -fsLS https://get.chezmoi.io/lb)" -- init --apply bgeneto

Entire fleet:
ansible-playbook -i inventory.ini workstation.yml
```

## My specific recommendation

Use this combination:

```text
chezmoi
├── all dotfiles
├── package bootstrap
├── Antidote installation
├── Starship configuration
├── machine profiles
└── one-line initial setup

mise
├── language runtimes
├── development CLI tools
└── per-project tool versions

Ansible
└── optional simultaneous fleet rollout
```

Do **not** build a large bespoke `install.sh` containing everything. Make chezmoi the stable bootstrap controller, keep scripts small and idempotent, and use profiles to prevent desktop-only components from being installed on servers.

---

**Sources:**

- [Install - chezmoi](https://www.chezmoi.io/install/?utm_source=chatgpt.com)
- [Getting Started | mise-en-place](https://mise.jdx.dev/getting-started?utm_source=chatgpt.com)
- [ansible-pull — Ansible Core Documentation](https://docs.ansible.com/projects/ansible-core/devel/cli/ansible-pull.html?utm_source=chatgpt.com)



---
Powered by [ChatGPT Exporter](https://www.chatgptexporter.com)