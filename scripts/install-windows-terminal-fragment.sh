#!/usr/bin/env bash
# Install the Catppuccin Mocha color scheme for Windows Terminal (WSL only).
#
# Windows Terminal fragments cannot change `profiles.defaults`, so this adds
# the scheme only; select it on your WSL profile afterwards (see below).
set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
src="$repo/docs/windows-terminal/catppuccin-mocha.json"

if [[ ! -f "$src" ]]; then
    printf 'fragment not found: %s\n' "$src" >&2
    exit 1
fi

if ! command -v cmd.exe >/dev/null 2>&1; then
    cat <<EOF
Windows Terminal integration requires WSL with access to cmd.exe.
Copy this file manually on Windows:
  $src
to:
  %LOCALAPPDATA%\\Microsoft\\Windows Terminal\\Fragments\\dotfiles\\catppuccin-mocha.json
EOF
    exit 0
fi

local_appdata="$(cmd.exe /c 'echo %LOCALAPPDATA%' 2>/dev/null | tr -d '\r')"
if [[ -z "$local_appdata" ]]; then
    printf 'could not resolve %%LOCALAPPDATA%% via cmd.exe\n' >&2
    exit 1
fi

dest_dir="$(wslpath -u "$local_appdata")/Microsoft/Windows Terminal/Fragments/dotfiles"
mkdir -p "$dest_dir"
cp "$src" "$dest_dir/catppuccin-mocha.json"

cat <<EOF
Installed Windows Terminal fragment: $dest_dir/catppuccin-mocha.json

Next steps (one time), in Windows Terminal:
  1. Restart Windows Terminal.
  2. Settings -> your WSL profile -> Appearance.
  3. Color scheme:        Catppuccin Mocha
     Font face:           FiraCode Nerd Font Mono
     (install the font on Windows first - see README)
  4. Optional: set the same scheme/font under "Defaults" to apply everywhere.
EOF
