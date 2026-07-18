# Native Zsh completion. Must run before fzf-tab is loaded.

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
