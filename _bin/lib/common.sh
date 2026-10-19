# Shared helpers for the pipeline toolkit (lane, heavy, gate, main-health, ci-watch).
# Sourced, never executed. bash 3.2 compatible (macOS /bin/bash); needs jq.
#
# State lives under $LANES_HOME (default ~/.claude/lanes):
#   registry/<slug>.json   one record per lane           (lane)
#   claims/<name>/         atomic mkdir claims             (lane)
#   locks/<slot>/          heavy-command slots             (heavy)
#   main-health.json       newest settled main CI run      (main-health)
#   flaky.json             known-flaky signatures          (main-health, ci-watch)
#
# Kill switch: LANES_OFF=1 turns every hook into a no-op and every slot into a pass-through.

LANES_HOME="${LANES_HOME:-$HOME/.claude/lanes}"
LANES_BIN="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
LANES_REPO_SLUG="${LANES_REPO_SLUG:-amiara-ai/amiara-stack}"
LANES_MAIN_CHECKOUT="${LANES_MAIN_CHECKOUT:-$HOME/Desktop/Resources/Amiara/amiara-stack}"

lanes_die() { printf '%s: %s\n' "${0##*/}" "$*" >&2; exit 1; }
lanes_warn() { printf '%s: %s\n' "${0##*/}" "$*" >&2; }
lanes_now() { date -u +%Y-%m-%dT%H:%M:%SZ; }
lanes_epoch() { date +%s; }

lanes_need() {
  local c
  for c in "$@"; do command -v "$c" >/dev/null 2>&1 || lanes_die "needs $c on PATH"; done
}

# Write stdin to $1 atomically (tmp file in the same dir, then mv).
lanes_write() {
  local dest="$1" tmp
  mkdir -p "$(dirname "$dest")" || return 1
  tmp="$(mktemp "$dest.XXXXXX")" || return 1
  cat > "$tmp" && mv -f "$tmp" "$dest"
}

# Is pid $1 alive? (kill -0 also succeeds for other users' processes we can't signal → EPERM counts as alive)
lanes_pid_alive() {
  [ -n "$1" ] || return 1
  kill -0 "$1" 2>/dev/null && return 0
  ps -p "$1" >/dev/null 2>&1
}

# The Claude Code session record for a session id, from ~/.claude/sessions/<pid>.json (live sessions only).
lanes_session_record() {
  local f
  for f in "$HOME"/.claude/sessions/*.json; do
    [ -f "$f" ] || continue
    if jq -e --arg s "$1" '.sessionId == $s' "$f" >/dev/null 2>&1; then
      lanes_pid_alive "$(jq -r .pid "$f")" && { cat "$f"; return 0; }
    fi
  done
  return 1
}

# Absolute git toplevel of $1 (default: cwd), or nothing.
lanes_toplevel() { git -C "${1:-.}" rev-parse --show-toplevel 2>/dev/null; }

# The main checkout that owns the worktree at $1 (parent of the common .git dir).
lanes_main_of() {
  local common
  common=$(git -C "${1:-.}" rev-parse --path-format=absolute --git-common-dir 2>/dev/null) || return 1
  dirname "$common"
}

# Workspace package dirs (relative, e.g. apps/api, packages/core) for the file list on stdin.
# A file maps to the deepest dir under apps/ packages/ tools/ that holds a package.json.
lanes_pkg_dirs() {
  local root="$1" f d
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    case "$f" in apps/*|packages/*|tools/*) ;; *) continue ;; esac
    d=$(dirname "$f")
    while [ "$d" != "." ] && [ "$d" != "/" ]; do
      if [ -f "$root/$d/package.json" ]; then printf '%s\n' "$d"; break; fi
      d=$(dirname "$d")
    done
  done | sort -u
}

# package.json "name" of a workspace dir.
lanes_pkg_name() { jq -r '.name // empty' "$1/$2/package.json" 2>/dev/null; }

# Test runner of a workspace dir: vitest | jest | node | none.
lanes_pkg_runner() {
  local pj="$1/$2/package.json" t
  [ -f "$pj" ] || { echo none; return; }
  t=$(jq -r '.scripts.test // ""' "$pj")
  case "$t" in
    *vitest*) echo vitest ;;
    *jest*) echo jest ;;
    *"node --test"*|*"tsx --test"*|*"node --import"*"--test"*) echo node ;;
    "") echo none ;;
    *) echo other ;;
  esac
}

# Free memory in MB that macOS can hand out without swapping: free + inactive + speculative pages.
lanes_free_mb() {
  vm_stat 2>/dev/null | awk '
    /page size of/ { for (i=1;i<=NF;i++) if ($i ~ /^[0-9]+$/) ps=$i }
    /Pages free/ { gsub(/\./,"",$3); f=$3 }
    /Pages inactive/ { gsub(/\./,"",$3); n=$3 }
    /Pages speculative/ { gsub(/\./,"",$3); s=$3 }
    END { if (!ps) ps=16384; printf "%d\n", (f+n+s)*ps/1048576 }'
}

lanes_load1() { sysctl -n vm.loadavg 2>/dev/null | awk '{ printf "%d\n", $2 }'; }
