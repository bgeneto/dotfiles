# Modern command aliases

alias ls='eza --icons=auto --group-directories-first'
alias ll='eza -lbF --icons=auto --group-directories-first'

alias la='eza \
  -lbhHigmuSa \
  --icons=auto \
  --group-directories-first \
  --time-style=long-iso \
  --color-scale=all'

alias lt='eza \
  --tree \
  --level=2 \
  --icons=auto \
  --group-directories-first'

alias free='free -h'
alias df='df -hT'

alias update='sudo apt update'
alias upgrade='sudo apt update && sudo apt full-upgrade'
alias inst='sudo apt install'
alias remove='sudo apt remove'
alias search='apt search'

alias listen='sudo lsof -i -P -n | grep LISTEN'

alias dps='docker ps'
alias dpsa='docker ps -a'
alias dsp='docker system prune'
alias dcb='docker compose build'
alias dcu='docker compose up'
alias dcud='docker compose up -d'
alias dcd='docker compose down'
alias dcps='docker compose ps'
alias dcl='docker compose logs'
alias dclf='docker compose logs -f'
