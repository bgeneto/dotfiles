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

# Docker / Compose shortcuts. Names follow the Oh My Zsh docker-compose and
# docker plugins so upstream docs and pasted commands work unchanged;
# dcu/dcud/dcd are local short forms kept alongside dcup/dcupd/dcdn.
# `dcb` shadows iproute2's /usr/sbin/dcb (data center bridging); `dcv` would
# shadow the NICE DCV client if installed.
alias dco='docker compose'
alias dcb='docker compose build'
alias dcc='docker compose config'
alias dce='docker compose exec'
alias dcps='docker compose ps'
alias dcrestart='docker compose restart'
alias dcrm='docker compose rm'
alias dcr='docker compose run'
alias dcstop='docker compose stop'
alias dcup='docker compose up'
alias dcu='docker compose up'
alias dcupb='docker compose up --build'
alias dcupd='docker compose up -d'
alias dcud='docker compose up -d'
alias dcupdb='docker compose up -d --build'
alias dcupw='docker compose up --watch'
alias dcupwb='docker compose up --watch --build'
alias dcdn='docker compose down'
alias dcd='docker compose down'
alias dcl='docker compose logs'
alias dclf='docker compose logs -f'
alias dclF='docker compose logs -f --tail 0'
alias dcpull='docker compose pull'
alias dcstart='docker compose start'
alias dck='docker compose kill'
alias dcv='docker compose version'
alias dcsts='docker compose stats'
alias dci='docker compose images'

# Standalone docker (OMZ docker plugin naming). Deliberately omitted:
# dsta (stops every running container) and `drm!` (force remove). `dvi` and
# `dcv` would shadow TeX DVI tooling / the NICE DCV client if installed.
# system
alias dps='docker ps'
alias dpsa='docker ps -a'
alias dsp='docker system prune'
alias dsprune='docker system prune'
# build / images
alias dbl='docker build'
alias dib='docker image build'
alias dils='docker image ls'
alias dii='docker image inspect'
alias dirm='docker image rm'
alias dit='docker image tag'
alias dipu='docker image push'
alias dipru='docker image prune -a'
alias dpu='docker pull'
# containers
alias dr='docker container run'
alias drit='docker container run -it'
alias drm='docker container rm'
alias dxc='docker container exec'
alias dxcit='docker container exec -it'
alias dst='docker container start'
alias dstp='docker container stop'
alias drs='docker container restart'
alias dcls='docker container ls'
alias dclsa='docker container ls -a'
alias dcin='docker container inspect'
alias dcprune='docker container prune'
alias dlo='docker container logs'
alias dpo='docker container port'
alias dtop='docker top'
alias dsts='docker stats'
# networks
alias dnc='docker network create'
alias dncn='docker network connect'
alias dndcn='docker network disconnect'
alias dni='docker network inspect'
alias dnls='docker network ls'
alias dnrm='docker network rm'
alias dnprune='docker network prune'
# volumes
alias dvi='docker volume inspect'
alias dvls='docker volume ls'
alias dvprune='docker volume prune'

# Create a .tar.gz with parallel gzip (usage: compress archive.tar.gz path...).
alias compress='tar --use-compress-program="pigz -k -5" -cf'

# Entire command history (plain `history` shows only the last 500 events).
alias fullhistory='fc -l 1'
