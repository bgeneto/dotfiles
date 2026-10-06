# Helper functions

# `history` lists the last 500 events. Zsh's `fc -l` default is only the last
# 16. Arguments pass through unchanged (`history 1` lists everything,
# `history -20` the last 20).
history() {
  if (( $# )); then
    fc -l "$@"
  else
    fc -l -500
  fi
}

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
  source "$ANTIDOTE_SRC/antidote.zsh" || return

  antidote update || return
  antidote bundle < "$ZSH_PLUGINS_FILE" >| "$ZSH_PLUGINS_BUNDLE"

  exec zsh
}

# Diagnose PATH / runtime issues (mise, nvm/pyenv shadowing, WSL /mnt/c paths).
dotfiles-doctor() {
  local -a problems=()
  local cmd resolved current dups legacy

  print -r -- "dotfiles doctor"
  print -r -- "---------------"
  print -r -- "shell:       ${SHELL:-?} (zsh $ZSH_VERSION)"
  print -r -- "ZDOTDIR:     ${ZDOTDIR:-<unset>}"
  print -r -- "zshrc:       ${ZDOTDIR:-$HOME}/.zshrc"
  print -r -- "VIRTUAL_ENV: ${VIRTUAL_ENV:-<none>}"

  if (( $+commands[mise] )); then
    print -r -- "mise:        $(command -v mise)"
    current="$(mise current 2>/dev/null)"
    if [[ -n "$current" ]]; then
      print -r -- "$current" | sed 's/^/  current:     /'
    fi
  else
    print -r -- "mise:        <missing>"
    problems+=("mise is not on PATH (run chezmoi apply)")
  fi

  print -r -- ""
  for cmd in node npm python python3 pip uv go rustc java; do
    resolved="${commands[$cmd]:-}"
    if [[ -z "$resolved" ]]; then
      printf '%-12s %s\n' "$cmd" "missing"
      continue
    fi
    printf '%-12s %s\n' "$cmd" "$resolved"
    case "$resolved" in
      /mnt/c/*)         problems+=("$cmd resolves to the Windows filesystem ($resolved)") ;;
      "$HOME/.nvm/"*)   problems+=("$cmd comes from nvm ($resolved); mise should provide it after cleanup") ;;
      "$HOME/.pyenv/"*) problems+=("$cmd comes from pyenv ($resolved); mise should provide it after cleanup") ;;
    esac
  done

  print -r -- ""
  legacy="$ZDOTDIR/conf.d/90-migrated-local.zsh"
  if [[ -f "$legacy" ]] && grep -qE 'PYENV_ROOT|NVM_DIR|pyenv init|nvm\.sh' "$legacy" 2>/dev/null; then
    problems+=("$legacy still initializes nvm/pyenv; see README migration notes")
  fi

  dups="$(print -l $path | sort | uniq -d)"
  if [[ -n "$dups" ]]; then
    problems+=("PATH has duplicate entries: ${dups//$'\n'/, }")
  fi

  print -r -- "---------------"
  if (( ${#problems} )); then
    print -r -- "Problems found:"
    local p
    for p in "${problems[@]}"; do
      print -r -- "  - $p"
    done
  else
    print -r -- "No problems found."
  fi
}
