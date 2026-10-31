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

# Diagnose PATH / runtime issues and explain Python environment ownership.
dotfiles-doctor() {
  local -a problems=()
  local -a notes=()
  local cmd resolved current dups legacy pyenv_root version_dir version_file line pin
  local mise_python_files=unknown settings
  pyenv_root="${PYENV_ROOT:-$HOME/.pyenv}"

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
    if settings="$(mise settings get idiomatic_version_file_enable_tools 2>/dev/null)"; then
      if [[ "$settings" == *'"python"'* ]]; then
        mise_python_files=yes
      else
        mise_python_files=no
      fi
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
      "$pyenv_root/"*)
        if [[ -n "${VIRTUAL_ENV:-}" && "$resolved" == "$VIRTUAL_ENV/"* ]]; then
          : # An explicitly active virtualenv is expected to take precedence.
        elif [[ "$cmd" == python || "$cmd" == python3 ]]; then
          notes+=("$cmd resolves through pyenv ($resolved); verify this is the intended interpreter")
        fi ;;
    esac
  done

  print -r -- ""
  if [[ -n "${VIRTUAL_ENV:-}" && -x "$VIRTUAL_ENV/bin/python" &&
        -n "${commands[python]:-}" && "${commands[python]}" != "$VIRTUAL_ENV/bin/python" ]]; then
    problems+=("VIRTUAL_ENV is set to $VIRTUAL_ENV, but python resolves to ${commands[python]}; check PATH precedence")
  fi

  # Inspect the nearest version file, as pyenv does. Numeric pins and names
  # such as pyenv-virtualenv's are distinct; neither is selected by mise by
  # default. Do not assume an arbitrary name corresponds to an installed venv.
  version_dir="$PWD"
  while true; do
    version_file="$version_dir/.python-version"
    if [[ -f "$version_file" && -r "$version_file" ]]; then
      while IFS= read -r line || [[ -n "$line" ]]; do
        line="${line%%\#*}"
        for pin in ${(z)line}; do
          [[ "$pin" == system || "$pin" =~ '^[0-9]+(\.[0-9]+)*([a-zA-Z][a-zA-Z0-9.+_-]*)?$' ]] && continue
          if [[ "$mise_python_files" == yes ]]; then
            problems+=("$version_file contains non-numeric Python pin '$pin'; mise Python version-file discovery is enabled and may treat it as a mise version")
          elif [[ "$mise_python_files" == no ]]; then
            notes+=("$version_file contains non-numeric Python pin '$pin'; mise does not use this pin to select or activate an environment")
          else
            notes+=("$version_file contains non-numeric Python pin '$pin'; check which Python environment manager selects it")
          fi
        done
      done < "$version_file"
      break
    fi
    [[ "$version_dir" == / ]] && break
    version_dir="${version_dir:h}"
  done

  legacy="${ZDOTDIR:-$HOME}/conf.d/90-migrated-local.zsh"
  if [[ -f "$legacy" ]] && grep -qE 'NVM_DIR|nvm\.sh' "$legacy" 2>/dev/null; then
    problems+=("$legacy initializes nvm; check for conflicts with mise's Node")
  fi
  if [[ -f "$legacy" ]] && grep -qE 'PYENV_ROOT|pyenv init|pyenv virtualenv-init' "$legacy" 2>/dev/null; then
    notes+=("$legacy initializes pyenv; check PATH precedence if it conflicts with mise")
  fi

  dups="$(print -l $path | sort | uniq -d)"
  if [[ -n "$dups" ]]; then
    problems+=("PATH has duplicate entries: ${dups//$'\n'/, }")
  fi

  print -r -- "---------------"
  if (( ${#notes} )); then
    print -r -- "Notes:"
    local note
    for note in "${notes[@]}"; do
      print -r -- "  - $note"
    done
  fi
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
