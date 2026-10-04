# Prefer bat for man pages. Keep `less` as the general pager: bat itself
# consults PAGER when it needs to page long output, so `PAGER=bat` is a trap.

if (( $+commands[bat] )); then
  export MANPAGER="sh -c 'col -bx | bat -l man -p'"
  export MANROFFOPT='-c'
fi

# Older revisions of this repo set PAGER=bat; that value leaks into nested
# shells and makes bat page itself. Drop it so the default below applies.
if [[ "${PAGER:-}" == "bat" || "${PAGER:-}" == "batcat" ]]; then
  unset PAGER
fi

if (( $+commands[less] )); then
  export PAGER="${PAGER:-less}"
elif (( $+commands[more] )); then
  export PAGER="${PAGER:-more}"
fi
