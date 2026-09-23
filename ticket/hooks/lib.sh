# Shared helpers for the ticket skill's CLI, hooks and status line.
# Sourced, never executed. Must stay bash 3.2 compatible (macOS /bin/bash).

TICKET_STATE_DIR="${TICKET_STATE_DIR:-$HOME/.claude/state/ticket}"
TICKET_SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
TICKET_CLI="$TICKET_SKILL_DIR/bin/ticket"

# The directory holding .claude/linear.json at or above $1 — the "repo" every binding is keyed by.
# Walks the path as a string, so it works for files that do not exist yet. Prints the path as
# found (not canonicalized) so callers can strip it as a prefix; canonicalize with ticket_canon.
ticket_find_root() {
  local d="$1"
  while [ -n "$d" ] && [ "$d" != "/" ] && [ "$d" != "." ]; do
    if [ -f "$d/.claude/linear.json" ]; then
      printf '%s\n' "$d"
      return 0
    fi
    d=$(dirname "$d")
  done
  return 1
}

ticket_canon() {
  (cd "$1" 2>/dev/null && pwd -P) || printf '%s\n' "$1"
}

ticket_state_file() {
  printf '%s/%s.json\n' "$TICKET_STATE_DIR" "$1"
}

# "active", "exempt" or "none" for session $1 in repo $2.
ticket_binding_kind() {
  local f
  f=$(ticket_state_file "$1")
  [ -f "$f" ] || { echo none; return 0; }
  jq -r --arg r "$2" '(.repos[$r] // {}) | if .active then "active" elif .exempt then "exempt" else "none" end' "$f" 2>/dev/null || echo none
}

# "CB-346 — title [status]" for session $1 in repo $2, or nothing.
ticket_active_line() {
  local f
  f=$(ticket_state_file "$1")
  [ -f "$f" ] || return 0
  jq -r --arg r "$2" '(.repos[$r].active // empty) | "\(.id) — \(.title // "")" + (if (.status // "") != "" then " [\(.status)]" else "" end)' "$f" 2>/dev/null
}

# Team keys as an ERE alternation, e.g. "CB" or "CB|ENG".
ticket_keys_re() {
  jq -r '((.teamKeys // []) + [.team.key // empty]) | unique | map(select(. != "")) | join("|")' "$1/.claude/linear.json" 2>/dev/null
}
