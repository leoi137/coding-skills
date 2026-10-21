#!/usr/bin/env bash
# PreToolUse gate for the ticket skill.
#
#   Edit / Write / NotebookEdit  — the first edit in a repo with .claude/linear.json needs a ticket
#                                  bound to the session (or an explicit "no ticket" exemption).
#   Bash `git commit`            — the message must carry a ticket ID of the repo's team.
#   Bash `gh pr create`          — the title or body must carry a ticket ID.
#
# Outside such a repo it does nothing. Any internal failure allows the call: a broken hook must
# never wedge a session, and the commit gate still backs the edit gate up.
set -uo pipefail

. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)/lib.sh" 2>/dev/null || exit 0
command -v jq >/dev/null || exit 0

input=$(cat)
field() { printf '%s' "$input" | jq -r "$1 // empty" 2>/dev/null; }

tool=$(field '.tool_name')
case "$tool" in
  Edit|Write|MultiEdit|NotebookEdit) ;;
  Bash)
    # Fast path: this hook sees every shell command, so bail before any other work.
    cmd=$(field '.tool_input.command')
    case "$cmd" in *commit*|*"pr create"*) ;; *) exit 0 ;; esac
    ;;
  *) exit 0 ;;
esac
session=$(field '.session_id')
cwd=$(field '.cwd')
[ -n "$cwd" ] || cwd="$PWD"

deny() {
  jq -n --arg r "$1" '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "deny", permissionDecisionReason: $r}}'
  exit 0
}

bound_note() {
  local line
  line=$(ticket_active_line "$session" "$1")
  if [ -n "$line" ]; then
    printf 'Bound in this session: %s.' "$line"
  elif [ "$(ticket_binding_kind "$session" "$1")" = exempt ]; then
    printf 'This session is exempt from the edit gate, but anything committed still needs a ticket — ask the user which one, or resolve one with the `ticket` skill.'
  else
    printf 'No ticket is bound in this session yet — resolve one with the `ticket` skill first.'
  fi
}

gate_edit() {
  local path found root rel pat kind key
  path=$(field '.tool_input.file_path // .tool_input.notebook_path')
  [ -n "$path" ] || exit 0
  case "$path" in /*) ;; *) path="$cwd/$path" ;; esac

  found=$(ticket_find_root "$(dirname "$path")") || exit 0
  rel="${path#"$found"/}"
  root=$(ticket_canon "$found")

  while IFS= read -r pat; do
    [ -n "$pat" ] || continue
    pat="${pat//\*\*/*}"
    # shellcheck disable=SC2254 — the pattern is meant to glob
    case "$rel" in $pat) exit 0 ;; esac
  done < <(jq -r '.exemptPaths[]? // empty' "$found/.claude/linear.json" 2>/dev/null)

  kind=$(ticket_binding_kind "$session" "$root")
  case "$kind" in active|exempt) exit 0 ;; esac

  key=$(jq -r '(.teamKeys // [])[0] // .team.key // "ABC"' "$found/.claude/linear.json" 2>/dev/null)
  deny "Linear gate: no ticket is bound to this session for $root (you are editing $rel). Every change in this repo belongs to a Linear ticket.

Load the \`ticket\` skill and resolve one before editing:
- The user named a ticket, or the lane's .lane/PLAN.md names one → verify it with get_issue, then bind it.
- Otherwise find candidates and ask the user once with AskUserQuestion: continue an existing ticket, create a new one, or no ticket for this session.
- Cannot ask the user (subagent or background run)? Stop and report that this work needs a ticket.

Bind:   $TICKET_CLI bind $key-123 --title \"…\" --status \"In Progress\" --url \"…\" --repo \"$root\" --session $session
No ticket, only if the user chose it:   $TICKET_CLI exempt \"<reason>\" --repo \"$root\" --session $session
Then retry this edit."
}

# First directory a command runs git in: `git -C <dir>`, else the first `cd <dir>`, else the cwd.
command_dir() {
  local cmd="$1" d
  d=$(printf '%s' "$cmd" | grep -oE "git[[:space:]]+-C[[:space:]]+(\"[^\"]+\"|'[^']+'|[^[:space:];&|]+)" | head -1 | sed -E 's/^git[[:space:]]+-C[[:space:]]+//')
  if [ -z "$d" ]; then
    d=$(printf '%s' "$cmd" | grep -oE "(^|[;&|(][[:space:]]*|[[:space:]])cd[[:space:]]+(\"[^\"]+\"|'[^']+'|[^[:space:];&|)]+)" | head -1 | sed -E 's/^.*cd[[:space:]]+//')
  fi
  d="${d#[\"\']}"; d="${d%[\"\']}"
  case "$d" in
    "") d="$cwd" ;;
    "~"*) d="$HOME${d#\~}" ;;
    /*) ;;
    *) d="$cwd/$d" ;;
  esac
  printf '%s\n' "$d"
}

# Contents of the file passed with any of the given flags (`-F f`, `--file f`, `--file=f`), if readable.
flag_file() {
  local cmd="$1" dir="$2" flags="$3" f
  f=$(printf '%s' "$cmd" | grep -oE "(^|[[:space:]])($flags)(=|[[:space:]]+)(\"[^\"]+\"|'[^']+'|[^[:space:];&|]+)" | head -1 | sed -E "s/^[[:space:]]*($flags)(=|[[:space:]]+)//")
  f="${f#[\"\']}"; f="${f%[\"\']}"
  [ -n "$f" ] && [ "$f" != "-" ] || return 0
  case "$f" in "~"*) f="$HOME${f#\~}" ;; /*) ;; *) f="$dir/$f" ;; esac
  [ -r "$f" ] && cat "$f"
}

gate_bash() {
  local dir found root keys re is_commit=0 is_pr=0 text key gitdir

  printf '%s' "$cmd" | grep -Eq "(^|[;&|(][[:space:]]*|[[:space:]])git([[:space:]]+-C[[:space:]]+(\"[^\"]+\"|'[^']+'|[^[:space:]]+))?[[:space:]]+commit([[:space:]]|$)" && is_commit=1
  printf '%s' "$cmd" | grep -Eq 'gh[[:space:]]+pr[[:space:]]+create' && is_pr=1
  [ $is_commit = 1 ] || [ $is_pr = 1 ] || exit 0

  case "$cmd" in *NO_TICKET=1*) exit 0 ;; esac

  dir=$(command_dir "$cmd")
  found=$(ticket_find_root "$dir") || exit 0
  root=$(ticket_canon "$found")
  keys=$(ticket_keys_re "$found")
  [ -n "$keys" ] || exit 0
  re="(^|[^A-Za-z0-9])($keys)-[0-9]+"
  key="${keys%%|*}"

  if [ $is_commit = 1 ]; then
    text="$cmd
$(flag_file "$cmd" "$dir" '-F|--file')"
    printf '%s' "$text" | grep -Eq "$re" && exit 0
    # A merge being concluded keeps git's own "Merge branch …" message.
    gitdir=$(git -C "$dir" rev-parse --absolute-git-dir 2>/dev/null)
    [ -n "$gitdir" ] && [ -e "$gitdir/MERGE_HEAD" ] && exit 0
    # --amend --no-edit keeps HEAD's message.
    case "$cmd" in *--no-edit*)
      git -C "$dir" log -1 --format=%B 2>/dev/null | grep -Eq "$re" && exit 0 ;;
    esac
    deny "Linear gate: this commit message names no ticket. In $root every commit carries its Linear ID — end the subject with \" ($key-123)\", using the ticket this change belongs to (two tickets → two commits).
$(bound_note "$root")
Only if the user explicitly said this commit needs no ticket: prefix the command with NO_TICKET=1."
  fi

  if [ $is_pr = 1 ]; then
    text="$cmd
$(flag_file "$cmd" "$dir" '-F|--body-file')"
    printf '%s' "$text" | grep -Eq "$re" && exit 0
    deny "Linear gate: this PR names no ticket, so Linear cannot link it or move the ticket. Put the ID in the title — \"<subject> ($key-123)\" — and start the body with \"Fixes $key-123\" (closes it on merge) or \"Part of $key-123\" (links without closing). Use an explicit --title/--body rather than --fill.
$(bound_note "$root")
Only if the user explicitly said this PR needs no ticket: prefix the command with NO_TICKET=1."
  fi
  exit 0
}

case "$tool" in
  Edit|Write|MultiEdit|NotebookEdit) gate_edit ;;
  Bash) gate_bash ;;
esac
exit 0
