# fzf
#
# Ctrl+R: history
# Ctrl+T: files (fd)
# Alt+C: directories (fd)

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
