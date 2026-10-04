#!/usr/bin/env bash
# Migrate from zsh4humans / the legacy gist setup to this chezmoi-managed config.
# Official z4h uninstall notes:
#   https://github.com/romkatv/zsh4humans#uninstalling
# Legacy gist:
#   https://gist.github.com/bgeneto/7b8a806b930350ff6a3ebd952f569415
set -euo pipefail

XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

NEW_HISTFILE="$XDG_STATE_HOME/zsh/history"
Z4H_CACHE="${XDG_CACHE_HOME}/zsh4humans"
BACKUP_ROOT="$HOME/zsh-migration-backup"
STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
BACKUP_DIR="$BACKUP_ROOT/$STAMP"

is_z4h_zshrc() {
    local f="$1"
    [[ -f "$f" ]] || return 1
    grep -qE 'z4h|zsh4humans|powerlevel10k|romkatv' "$f" 2>/dev/null
}

needs_migration() {
    [[ -d "$Z4H_CACHE" ]] && return 0
    is_z4h_zshrc "$HOME/.zshrc" && return 0
    is_z4h_zshrc "${ZDOTDIR:-}/.zshrc" && return 0
    # Legacy home startup files still present while new ZDOTDIR is configured.
    if [[ -f "$HOME/.zshrc" ]] && [[ -f "$XDG_CONFIG_HOME/zsh/.zshrc" ]]; then
        return 0
    fi
    return 1
}

if ! needs_migration; then
    exit 0
fi

mkdir -p "$BACKUP_DIR" "$XDG_STATE_HOME/zsh" "$XDG_CONFIG_HOME/zsh/conf.d"

printf 'Migrating from zsh4humans / legacy zshrc → chezmoi setup\n'
printf 'Backup directory: %s\n' "$BACKUP_DIR"

# ---------------------------------------------------------------------------
# Preserve history: z4h default is ${ZDOTDIR:-$HOME}/.zsh_history
# New setup uses $XDG_STATE_HOME/zsh/history
# ---------------------------------------------------------------------------

pick_history_source() {
    local candidate best="" best_size=0 size
    local -a candidates=(
        "${HISTFILE:-}"
        "$HOME/.zsh_history"
        "${ZDOTDIR:-$HOME}/.zsh_history"
        "$XDG_CONFIG_HOME/zsh/.zsh_history"
    )

    for candidate in "${candidates[@]}"; do
        [[ -n "$candidate" && -f "$candidate" && -s "$candidate" ]] || continue
        size="$(wc -c <"$candidate" | tr -d ' ')"
        if (( size > best_size )); then
            best="$candidate"
            best_size="$size"
        fi
    done

    if [[ -n "$best" ]]; then
        printf '%s\n' "$best"
    fi
}

HISTORY_SRC="$(pick_history_source || true)"

if [[ -n "${HISTORY_SRC:-}" ]]; then
    printf 'Found history file: %s (%s bytes)\n' \
        "$HISTORY_SRC" "$(wc -c <"$HISTORY_SRC" | tr -d ' ')"

    cp -a "$HISTORY_SRC" "$BACKUP_DIR/$(basename "$HISTORY_SRC")"

    if [[ ! -f "$NEW_HISTFILE" ]]; then
        cp -a "$HISTORY_SRC" "$NEW_HISTFILE"
        printf 'Installed history at: %s\n' "$NEW_HISTFILE"
    elif cmp -s "$HISTORY_SRC" "$NEW_HISTFILE"; then
        printf 'New history already identical to source; left unchanged\n'
    else
        # Merge whole history entries (not raw lines). Line-level uniq breaks
        # multi-line commands that use backslash continuations: shared
        # continuation lines are dropped and leave a dangling timestamp header.
        cp -a "$NEW_HISTFILE" "$BACKUP_DIR/history.pre-merge"
        merge_tmp="$(mktemp)"
        awk '
            function flush(    key) {
                if (entry == "")
                    return
                key = entry
                sub(/^: [0-9]+:[0-9]+;/, "", key)
                if (!(key in seen)) {
                    seen[key] = 1
                    printf "%s", entry
                }
                entry = ""
                continuing = 0
            }
            {
                line = $0
                if (continuing) {
                    entry = entry line "\n"
                    continuing = (line ~ /\\$/)
                    if (!continuing)
                        flush()
                    next
                }
                if (line ~ /^: [0-9]+:[0-9]+;/) {
                    entry = line "\n"
                    if (line ~ /\\$/)
                        continuing = 1
                    else
                        flush()
                    next
                }
                # Non-extended history: one line per entry.
                entry = line "\n"
                flush()
            }
            END { flush() }
        ' "$HISTORY_SRC" "$NEW_HISTFILE" >"$merge_tmp"
        mv "$merge_tmp" "$NEW_HISTFILE"
        printf 'Merged history into: %s\n' "$NEW_HISTFILE"
    fi

    chmod 600 "$NEW_HISTFILE" 2>/dev/null || true
else
    printf 'No existing zsh history file found to migrate\n'
fi

# ---------------------------------------------------------------------------
# Optionally keep machine-specific blocks from the legacy gist ~/.zshrc
# ---------------------------------------------------------------------------

extract_local_overrides() {
    local src="$1"
    local dest="$XDG_CONFIG_HOME/zsh/conf.d/90-migrated-local.zsh"

    [[ -f "$src" ]] || return 0
    [[ -f "$dest" ]] && return 0

    if ! grep -qE 'oneapi|OpenBLAS|setvars\.sh' "$src" 2>/dev/null; then
        return 0
    fi

    cat >"$dest" <<'EOF'
# Migrated from legacy ~/.zshrc (zsh4humans / gist). Review and edit freely.
# This file is not managed by chezmoi.
# Runtime initializers (pyenv/nvm/cargo/bun) are intentionally NOT migrated;
# mise manages runtimes now. See the README migration notes.
# API keys / tokens are redacted during extraction; never store them here.
EOF

    # Copy only the known machine-specific sections (Intel oneAPI / OpenBLAS).
    # Sections are anchored on their title lines (the legacy format is
    # banner / title / banner / body) and stop at the next heading, so
    # pyenv/nvm/cargo/bun blocks — which have no trailing banner — are never
    # carried over. Secret-looking lines are dropped as a second line of
    # defence. (A naive "copy to EOF" once captured unrelated settings and
    # API keys appended after those blocks.)
    awk '
        function heading(s) { return s ~ /^#[[:space:]]+[A-Za-z]/ }
        function target(s)  { return tolower(s) ~ /intel mkl|openblas/ }
        function secret(s) {
            return tolower(s) ~ /(api[_-]?key|api[_-]?token|access[_-]?token|auth[_-]?token|secret|password|passwd|bearer)[[:space:]]*[=:]/
        }

        heading($0) {
            if (target($0)) {
                print "# -------------------------"
                print $0
                keep = 1
                next
            }
            keep = 0
            next
        }
        keep {
            if ($0 ~ /^# -+[[:space:]]*$/) next
            if (secret($0)) next
            print
        }
    ' "$src" >>"$dest"

    if ! grep -qE '^[^#[:space:]]' "$dest"; then
        rm -f "$dest"
        return 0
    fi

    chmod 600 "$dest"
    printf 'Wrote local overrides: %s\n' "$dest"
    printf 'pyenv/nvm/cargo initializers were skipped on purpose; mise manages runtimes.\n'
    printf 'Secret-looking lines were redacted; keep keys in conf.d/99-secrets.zsh (mode 600).\n'
}

if [[ -f "$HOME/.zshrc" ]]; then
    extract_local_overrides "$HOME/.zshrc"
fi

# ---------------------------------------------------------------------------
# Backup and remove legacy startup files / z4h cache / p10k
# (chezmoi will deploy the new ~/.zshenv and ~/.config/zsh/* next)
# ---------------------------------------------------------------------------

backup_path() {
    local path="$1"
    local name="$2"
    if [[ -e "$path" || -L "$path" ]]; then
        mv "$path" "$BACKUP_DIR/$name"
        printf 'Moved %s → %s/%s\n' "$path" "$BACKUP_DIR" "$name"
    fi
}

# Home-directory zsh startup files from z4h / the gist.
backup_path "$HOME/.zshrc" "dot_zshrc"
backup_path "$HOME/.zshenv" "dot_zshenv"
backup_path "$HOME/.zprofile" "dot_zprofile"
backup_path "$HOME/.zlogin" "dot_zlogin"
backup_path "$HOME/.zlogout" "dot_zlogout"

# Do not delete history until backed up; retire the old path to avoid split brains.
if [[ -f "$HOME/.zsh_history" ]]; then
    backup_path "$HOME/.zsh_history" "dot_zsh_history"
fi

backup_path "$HOME/.p10k.zsh" "dot_p10k.zsh"

# Powerlevel10k may leave multiple configs.
shopt -s nullglob
for p10k in "$HOME"/.p10k*.zsh; do
    backup_path "$p10k" "$(basename "$p10k")"
done
shopt -u nullglob

if [[ -d "$Z4H_CACHE" ]]; then
    mv "$Z4H_CACHE" "$BACKUP_DIR/zsh4humans-cache"
    printf 'Moved %s → %s/zsh4humans-cache\n' "$Z4H_CACHE" "$BACKUP_DIR"
fi

# Prior installer backups, if present.
if [[ -d "$HOME/zsh-backup" ]]; then
    mv "$HOME/zsh-backup" "$BACKUP_DIR/zsh-backup-from-z4h-installer"
    printf 'Moved ~/zsh-backup into migration backup\n'
fi

cat <<EOF

Migration complete.
  History:  $NEW_HISTFILE
  Backups:  $BACKUP_DIR

Next: chezmoi will apply the new config. Then restart the terminal
(or run: exec zsh) — restarting only the shell may not be enough if
the old zshenv was already sourced in this session.
EOF
