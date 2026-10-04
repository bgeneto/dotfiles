# bat theme (vendored from catppuccin/bat; cache rebuilt by a chezmoi script).
# Only set BAT_THEME when the theme file is actually deployed.
if [[ -r "${XDG_CONFIG_HOME:-$HOME/.config}/bat/themes/Catppuccin Mocha.tmTheme" ]]; then
  export BAT_THEME="${BAT_THEME:-Catppuccin Mocha}"
fi
