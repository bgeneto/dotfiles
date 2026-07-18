# Terminal key fixes for common emulators (Windows Terminal, VS Code, tmux, etc.)

bindkey -e

# Home / End
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[OH' beginning-of-line
bindkey '^[OF' end-of-line
bindkey '^[[1~' beginning-of-line
bindkey '^[[4~' end-of-line

# Delete
bindkey '^[[3~' delete-char

# Ctrl+Left / Ctrl+Right (word navigation)
bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word
bindkey '^[[5D' backward-word
bindkey '^[[5C' forward-word
bindkey '^[OD' backward-word
bindkey '^[OC' forward-word

# Prefix-aware history search using the up/down arrows.
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^[OA' history-substring-search-up
bindkey '^[OB' history-substring-search-down
