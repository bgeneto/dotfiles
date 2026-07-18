# Helper functions

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
