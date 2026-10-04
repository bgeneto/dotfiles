# fzf
#
# Ctrl+R: history
# Ctrl+T: files (fd)
# Alt+C: directories (fd)
#
# Prefer a modern fzf (supports `fzf --zsh`). Older distro packages only
# ship example scripts under /usr/share/doc/fzf/examples/.

if (( $+commands[fzf] )); then
  # Exclusions must live in the fd commands themselves: fzf's own
  # `--walker-skip` only applies to its built-in walker, which is bypassed
  # whenever FZF_*_COMMAND supplies results.
  typeset -ga FZF_FD_EXCLUDES=(
    --exclude .git
    --exclude node_modules
    --exclude .venv
    --exclude dist
    --exclude target
    --exclude .cache
  )

  if (( $+commands[fd] )); then
    export FZF_DEFAULT_COMMAND="fd --type f --hidden --follow ${FZF_FD_EXCLUDES[*]}"
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND="fd --type d --hidden --follow ${FZF_FD_EXCLUDES[*]}"
  fi

  # Catppuccin Mocha (matches starship / bat / delta themes).
  export FZF_DEFAULT_OPTS="
    --height=60%
    --layout=reverse
    --border
    --info=inline
    --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8,fg:#cdd6f4
    --color=header:#f38ba8,info:#cba6f7,pointer:#f5e0dc,marker:#f5e0dc
    --color=fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8,selected-bg:#45475a
  "

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
