# fzf
#
# Ctrl+R: history
# Ctrl+T: files (fd)
# Alt+C: directories (fd)
#
# Prefer a modern fzf (supports `fzf --zsh`). Older distro packages only
# ship example scripts under /usr/share/doc/fzf/examples/.

if (( $+commands[fzf] )); then
  if (( $+commands[fd] )); then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
  fi

  export FZF_DEFAULT_OPTS="
    --height=60%
    --layout=reverse
    --border
    --info=inline
  "

  # --walker-skip needs fzf ≥ 0.46; omit on older builds.
  if fzf --help 2>&1 | grep -q -- '--walker'; then
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
  else
    export FZF_CTRL_T_OPTS="
      --preview '
        bat --color=always --style=numbers --line-range=:500 {} 2>/dev/null ||
        eza --tree --level=2 --color=always --icons=always {}
      '
    "
    export FZF_ALT_C_OPTS="
      --preview '
        eza --tree --level=2 --color=always --icons=always {}
      '
    "
  fi

  () {
    if fzf --help 2>&1 | grep -q -- '--zsh'; then
      source <(fzf --zsh)
      return
    fi

    # Legacy distro packages (no `fzf --zsh`).
    local -a prefix=(
      /usr/share/doc/fzf/examples
      /usr/share/fzf
      /usr/local/share/fzf
      "${HOME}/.local/share/fzf"
    )
    local dir
    for dir in "${prefix[@]}"; do
      if [[ -r "${dir}/key-bindings.zsh" ]]; then
        source "${dir}/key-bindings.zsh"
        [[ -r "${dir}/completion.zsh" ]] && source "${dir}/completion.zsh"
        return
      fi
    done
  }
fi
