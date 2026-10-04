#!/usr/bin/env bash
# Local validation for this chezmoi source repo. Not deployed — see .chezmoiignore.
set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo"

if ! command -v chezmoi >/dev/null 2>&1; then
    printf 'chezmoi is required for the template checks\n' >&2
    exit 1
fi

tmp_cfg="$(mktemp --suffix=.toml)"
trap 'rm -f "$tmp_cfg"' EXIT

cat >"$tmp_cfg" <<'EOF'
[data]
    elevated = false
EOF

chezmoi_run() {
    chezmoi --config "$tmp_cfg" --source "$repo" "$@"
}

fail=0
report_fail() {
    printf 'FAIL %s\n' "$1" >&2
    fail=1
}

printf '== rendered script templates (bash -n)\n'
for f in .chezmoiscripts/*.tmpl; do
    [[ -f "$f" ]] || continue
    if chezmoi_run execute-template <"$f" | bash -n; then
        printf 'ok   %s\n' "$f"
    else
        report_fail "$f"
    fi
done

printf '\n== raw bash scripts (bash -n)\n'
for f in .chezmoiscripts/*.sh; do
    [[ -f "$f" ]] || continue
    if bash -n "$f"; then
        printf 'ok   %s\n' "$f"
    else
        report_fail "$f"
    fi
done

printf '\n== zsh syntax (zsh -n)\n'
for f in dot_zshenv dot_config/zsh/dot_zshrc dot_config/zsh/conf.d/*.zsh; do
    [[ -f "$f" ]] || continue
    if zsh -n "$f"; then
        printf 'ok   %s\n' "$f"
    else
        report_fail "$f"
    fi
done

printf '\n== mise config template renders to valid TOML\n'
if chezmoi_run execute-template <dot_config/mise/config.toml.tmpl |
    python3 -c 'import sys, tomllib; tomllib.loads(sys.stdin.read())'; then
    printf 'ok   dot_config/mise/config.toml.tmpl\n'
else
    report_fail dot_config/mise/config.toml.tmpl
fi

printf '\n== init config template renders (no profile prompt)\n'
if chezmoi_run execute-template --init --promptString elevated=false \
    <.chezmoi.toml.tmpl | grep -q '^    elevated = false$'; then
    printf 'ok   .chezmoi.toml.tmpl\n'
else
    report_fail .chezmoi.toml.tmpl
fi

printf '\n== starship config is valid TOML\n'
if python3 -c 'import sys, tomllib; tomllib.loads(open(sys.argv[1], encoding="utf-8").read())' \
    dot_config/starship.toml; then
    printf 'ok   dot_config/starship.toml\n'
else
    report_fail dot_config/starship.toml
fi

printf '\n== Windows Terminal fragment is valid JSON\n'
for f in docs/windows-terminal/*.json; do
    [[ -f "$f" ]] || continue
    if python3 -m json.tool "$f" >/dev/null; then
        printf 'ok   %s\n' "$f"
    else
        report_fail "$f"
    fi
done

printf '\n== no leftover profile branching\n'
if grep -rn '\.profile' .chezmoi.toml.tmpl .chezmoiscripts dot_config 2>/dev/null; then
    report_fail "profile references"
else
    printf 'ok   no .profile references in templates\n'
fi

printf '\n== secret scan\n'
# Known key prefixes plus generic KEY/TOKEN/PASSWORD assignments. check.sh is
# excluded so its own patterns cannot self-match.
secret_pattern='(mxb_[A-Za-z0-9]{16,}|tvly-[A-Za-z0-9-]{16,}|ctx7sk-[A-Fa-f0-9-]{20,}|sk-[A-Za-z0-9]{24,}|ghp_[A-Za-z0-9]{30,}|github_pat_[A-Za-z0-9_]{30,}|AKIA[0-9A-Z]{16}|-----BEGIN [A-Z ]*PRIVATE KEY-----|(API[_-]?KEY|API[_-]?TOKEN|ACCESS[_-]?TOKEN|SECRET[_-]?KEY|PASSWORD|PASSWD)[[:space:]]*=[[:space:]]*"?[A-Za-z0-9_./+-]{12,})'
if grep -rInE "$secret_pattern" . --exclude-dir=.git --exclude=check.sh; then
    report_fail "potential secrets found (remove them and rotate the keys)"
else
    printf 'ok   no obvious secrets\n'
fi

printf '\n== semgrep deep scan (optional)\n'
if command -v semgrep >/dev/null 2>&1; then
    if semgrep scan --metrics=off --no-git-ignore --error --quiet \
        --config scripts/semgrep-rules.yaml . >/dev/null 2>&1; then
        printf 'ok   semgrep secrets ruleset\n'
    else
        report_fail "semgrep findings (run: semgrep scan --config scripts/semgrep-rules.yaml .)"
    fi
else
    printf 'skip semgrep not installed\n'
fi

if (( fail )); then
    printf '\nchecks failed\n' >&2
    exit 1
fi

printf '\nall checks passed\n'
