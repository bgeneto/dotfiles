# forgit provides interactive git via fzf (ga, glo, gd, …).
# Keep a few non-interactive shortcuts for speed.

alias gst='git status -sb'
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
