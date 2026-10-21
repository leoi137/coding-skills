#!/usr/bin/env bash
# PreToolUse(Bash) hook: route RAM-heavy commands (tsc, turbo lint/typecheck/test/build, package-wide
# vitest/jest, next build, integration specs) through `heavy`, so parallel sessions and subagents
# queue for machine-wide slots instead of thrashing a 16 GB Mac.
#
# It rewrites the command (updatedInput) and never decides permission. Claude Code checks permission
# rules against the REWRITTEN command (verified 2026-10-19), so an allow rule like
# `Bash(pnpm typecheck:*)` would stop matching and the user would get a prompt. It therefore only
# rewrites in bypassPermissions and auto sessions (auto's classifier ran a wrapped command without a
# prompt, verified 2026-10-21); default/acceptEdits/plan pass through untouched (the toolkit
# scripts — gate — still take their slots themselves). Foreground calls wait ≤60 s for a slot, then fail
# with exit 75 and the owner, telling the model to rerun with run_in_background (the Bash tool
# caps foreground calls at 10 minutes). Background calls queue without a limit.
#
# Fail-open: any internal problem lets the original command through. LANES_OFF=1 disables it.
set -uo pipefail

[ "${LANES_OFF:-}" = 1 ] && exit 0
command -v jq >/dev/null || exit 0
BIN="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
[ -x "$BIN/heavy" ] || exit 0

input=$(cat)
[ "$(printf '%s' "$input" | jq -r '.tool_name // empty' 2>/dev/null)" = Bash ] || exit 0
case "$(printf '%s' "$input" | jq -r '.permission_mode // empty' 2>/dev/null)" in bypassPermissions|auto) ;; *) exit 0 ;; esac
cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null)
[ -n "$cmd" ] || exit 0

# Cheap prefilter before forking the classifier: this hook sees every shell command.
case "$cmd" in
  *tsc*|*turbo*|*vitest*|*jest*|*typecheck*|*"next build"*|*test*|*build*|*lint*|*eslint*) ;;
  *) exit 0 ;;
esac

slots=$("$BIN/heavy" classify "$cmd" 2>/dev/null) || exit 0
[ -n "$slots" ] || exit 0

session=$(printf '%s' "$input" | jq -r '.session_id // empty' 2>/dev/null)
bg=$(printf '%s' "$input" | jq -r '.tool_input.run_in_background // false' 2>/dev/null)
wait_flag="--wait-max 60"
[ "$bg" = true ] && wait_flag=""

# single-quote the original command for the shell that runs the wrapper
quoted="'$(printf '%s' "$cmd" | sed "s/'/'\\\\''/g")'"
wrapped="\"$BIN/heavy\" $slots ${session:+--session $session }$wait_flag --sh $quoted"

printf '%s' "$input" | jq -c --arg c "$wrapped" --arg s "$slots" '
  {hookSpecificOutput: {
     hookEventName: "PreToolUse",
     updatedInput: (.tool_input + {command: $c}),
     additionalContext: ("heavy-guard: ran inside the machine-wide `" + $s + "` slot; if it exits 75 the slot was busy — rerun with run_in_background (`heavy status` shows the queue).")
  }}' 2>/dev/null || exit 0
exit 0
