# Prefer bat for man pages and as a general pager when available.

if (( $+commands[bat] )); then
  export MANPAGER="sh -c 'col -bx | bat -l man -p'"
  export MANROFFOPT='-c'
  export PAGER="${PAGER:-bat}"
fi
