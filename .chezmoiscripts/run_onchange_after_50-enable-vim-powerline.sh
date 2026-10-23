#!/usr/bin/env bash
set -euo pipefail

# Vim is linked to system libpython. The powerline module must be importable
# by /usr/bin/python3. mise's python3 is a different build and cannot satisfy
# that. Prefer the apt package (installed earlier when elevated=true); if it
# is missing, install the module with the system interpreter only.
plugin_dir="${HOME}/.vim/plugin"
dest="${plugin_dir}/powerline.vim"
debian_addon="/usr/share/vim/addons/plugin/powerline.vim"

mkdir -p "$plugin_dir"

if [[ -x /usr/bin/python3 ]] && ! /usr/bin/python3 -c 'import powerline' >/dev/null 2>&1; then
  if /usr/bin/python3 -m pip --version >/dev/null 2>&1; then
    /usr/bin/python3 -m pip install --user --disable-pip-version-check powerline-status
  else
    printf 'dotfiles: python3-powerline is missing and /usr/bin/python3 has no pip\n' >&2
  fi
fi

link_target=""
if [[ -f "$debian_addon" ]]; then
  link_target="$debian_addon"
elif [[ -x /usr/bin/python3 ]]; then
  link_target="$(/usr/bin/python3 -c 'import powerline, pathlib
p = pathlib.Path(powerline.__file__).resolve().parent / "bindings" / "vim" / "plugin" / "powerline.vim"
print(p if p.is_file() else "")' 2>/dev/null || true)"
fi

if [[ -z "$link_target" ]]; then
  printf 'dotfiles: powerline vim plugin not found; statusline stays disabled\n' >&2
  exit 0
fi

if [[ -L "$dest" && "$(readlink "$dest")" == "$link_target" ]]; then
  exit 0
fi

if [[ -e "$dest" ]]; then
  printf 'dotfiles: %s exists and is not the powerline addon link; leaving it alone\n' "$dest" >&2
  exit 0
fi

ln -s "$link_target" "$dest"
