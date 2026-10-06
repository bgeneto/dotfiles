# forgit provides interactive git via fzf (ga, glo, gd, …).
# Keep a few non-interactive shortcuts for speed.

# `git status -sb` prints only the branch line on a clean tree, so "clean" and
# "nothing to show" look the same. Print the short status plus a one-line
# summary of staged/unstaged/untracked changes.
gst() {
  local line output
  local staged=0 unstaged=0 untracked=0

  output=$(git status --short --branch "$@") || return

  print -r -- "$output"

  for line in ${(f)output}; do
    [[ $line == '## '* ]] && continue
    if [[ $line == '?? '* || $line == '!! '* ]]; then
      (( ++untracked ))
    else
      [[ ${line[1]} != ' ' ]] && (( ++staged ))
      [[ ${line[2]} != ' ' ]] && (( ++unstaged ))
    fi
  done

  if (( staged + unstaged + untracked == 0 )); then
    print -r -- 'nothing to commit, working tree clean'
  else
    print -r -- "$staged staged, $unstaged unstaged, $untracked untracked"
  fi
}

alias gsw='git switch'
alias gpr='git pull --rebase'
alias gp='git push'
alias gc='git commit'
alias gcm='git commit -m'
alias gca='git commit --amend --no-edit'
alias gb='git branch'
alias gclone='git clone --depth=1'

# Prefer delta for diffs when installed. Delta reads its theme from git
# config; see docs/delta/ and the README for the include snippet.
if (( $+commands[delta] )); then
  export GIT_PAGER="${GIT_PAGER:-delta}"
fi
