#!/usr/bin/env bash
# Behavioral checks for Python environment diagnostics; uses isolated fixtures.
set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT
mkdir -p "$tmp_dir/bin" "$tmp_dir/home/project/child" \
    "$tmp_dir/home/.pyenv/versions/example/bin" "$tmp_dir/other/bin"

cat >"$tmp_dir/bin/mise" <<'EOF'
#!/usr/bin/env bash
case "$*" in
  current) printf 'python 3.13\n' ;;
  'settings get idiomatic_version_file_enable_tools') printf '%s\n' "$TEST_MISE_SETTINGS" ;;
esac
EOF
printf '#!/bin/sh\nexit 0\n' >"$tmp_dir/home/.pyenv/versions/example/bin/python"
printf '#!/bin/sh\nexit 0\n' >"$tmp_dir/other/bin/python"
chmod +x "$tmp_dir/bin/mise" "$tmp_dir/home/.pyenv/versions/example/bin/python" "$tmp_dir/other/bin/python"

run_doctor() {
    local settings="$1" active="$2" search_path="$3"
    (cd "$tmp_dir/home/project/child" && \
        env -u VIRTUAL_ENV HOME="$tmp_dir/home" ZDOTDIR="$tmp_dir/home/zsh" \
        VIRTUAL_ENV="$active" PATH="$search_path" TEST_MISE_SETTINGS="$settings" \
        zsh -f -c 'source "$1"; dotfiles-doctor' -- "$repo/dot_config/zsh/conf.d/functions.zsh")
}

path_base="$tmp_dir/bin:/usr/bin:/bin"
printf 'example\n' >"$tmp_dir/home/project/.python-version"
output="$(run_doctor '["node", "python"]' '' "$path_base")"
[[ "$output" == *"non-numeric Python pin 'example'"* && "$output" == *'discovery is enabled'* ]]

output="$(run_doctor '["node"]' '' "$path_base")"
[[ "$output" == *"non-numeric Python pin 'example'"* && "$output" == *'mise does not use this pin'* ]]
[[ "$output" != *'Problems found:'* ]]

venv="$tmp_dir/home/.pyenv/versions/example"
output="$(run_doctor '["node"]' "$venv" "$venv/bin:$path_base")"
[[ "$output" != *'Problems found:'* && "$output" != *'resolves through pyenv'* ]]

output="$(run_doctor '["node"]' "$venv" "$tmp_dir/other/bin:$path_base")"
[[ "$output" == *'VIRTUAL_ENV is set to'* && "$output" == *'check PATH precedence'* ]]

printf '3.13\n' >"$tmp_dir/home/project/child/.python-version"
output="$(run_doctor '["node", "python"]' '' "$path_base")"
[[ "$output" != *'non-numeric Python pin'* ]]

printf '3.13.5/envs/example\n' >"$tmp_dir/home/project/child/.python-version"
output="$(run_doctor '["node", "python"]' '' "$path_base")"
[[ "$output" == *"non-numeric Python pin '3.13.5/envs/example'"* ]]

printf 'ok   Python environment diagnostics\n'
