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

# Application-mode arrows (SS3: ESC O {A,B,C,D}). These are plain
# Left/Right when the terminal has smkx enabled — not Alt/Ctrl.
# Binding them to *-word makes arrows jump a word at a time.
bindkey '^[OD' backward-char
bindkey '^[OC' forward-char

# Ctrl+Left / Ctrl+Right (word navigation)
bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word
bindkey '^[[5D' backward-word
bindkey '^[[5C' forward-word

# Alt+Left / Alt+Right (word navigation)
bindkey '^[[1;3D' backward-word
bindkey '^[[1;3C' forward-word

# Prefix-aware history search using the up/down arrows.
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^[OA' history-substring-search-up
bindkey '^[OB' history-substring-search-down

# Ctrl+Backspace: delete the previous shell word, stopping at punctuation
# (-, /, \, |, ., :, = …) as well as whitespace. Zsh's stock
# backward-kill-word (Alt+Backspace) treats every character in $WORDCHARS as
# part of the word, so "feature/foo-bar" is deleted in one gulp; emptying
# $WORDCHARS locally makes each press kill one segment instead. Same idea as
# z4h-backward-kill-word from zsh4humans.
dotfiles-backward-kill-word() {
  local WORDCHARS=''
  zle .backward-kill-word
}
zle -N dotfiles-backward-kill-word

# Ctrl+Backspace sends different bytes depending on the terminal:
#   ^H            xterm, Windows Terminal, Alacritty, …
#   ^[[27;5;127~  xterm with modifyOtherKeys
#   ^[[127;5u     kitty keyboard protocol (kitty, foot, …)
bindkey '^H'           dotfiles-backward-kill-word
bindkey '^[[27;5;127~' dotfiles-backward-kill-word
bindkey '^[[127;5u'    dotfiles-backward-kill-word
