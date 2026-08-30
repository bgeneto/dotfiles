# Native Zsh completion. Must run before fzf-tab is loaded.

mkdir -p "$XDG_CACHE_HOME/zsh/completions"
fpath=("$XDG_CACHE_HOME/zsh/completions" $fpath)

# Docker ships its own completion (includes `docker compose`). Regenerate when
# the docker binary is newer than the cached file.
if (( $+commands[docker] )); then
  _docker_comp="$XDG_CACHE_HOME/zsh/completions/_docker"
  if [[ ! -s $_docker_comp || ${commands[docker]} -nt $_docker_comp ]]; then
    if ! command docker completion zsh >| "$_docker_comp" 2>/dev/null; then
      rm -f "$_docker_comp"
    fi
  fi
  unset _docker_comp
fi

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
