#!/usr/bin/env bash
# PreToolUse(Agent) hook: every subagent runs on the model the user chose for this session — no
# silent downgrade from an agent type's own default, no Opus/Fable upgrade the user didn't pick
# (Fable burns through tokens). It sets tool_input.model to the session's model via updatedInput;
# it never denies and never decides permission.
#
# The session's model is the latest `message.model` in the transcript (follows /model switches).
# Verified 2026-10-19 on 2.1.303: tool_name is "Agent", the field is tool_input.model (opus |
# sonnet | haiku | fable), absent when omitted; hook payloads carry transcript_path. Forks are
# skipped (they always run on the parent's model).
#
# Fail-open: no transcript or an unknown model leaves the call untouched. LANES_OFF=1 disables it.
set -uo pipefail

[ "${LANES_OFF:-}" = 1 ] && exit 0
command -v jq >/dev/null || exit 0

input=$(cat)
case "$(printf '%s' "$input" | jq -r '.tool_name // empty' 2>/dev/null)" in Agent|Task) ;; *) exit 0 ;; esac
[ "$(printf '%s' "$input" | jq -r '.tool_input.subagent_type // empty' 2>/dev/null)" = fork ] && exit 0

transcript=$(printf '%s' "$input" | jq -r '.transcript_path // empty' 2>/dev/null)
[ -n "$transcript" ] && [ -f "$transcript" ] || exit 0
id=$(tail -n 400 "$transcript" 2>/dev/null | jq -r 'select(.type == "assistant") | .message.model // empty' 2>/dev/null \
  | grep '^claude-' | tail -1)
case "$id" in
  *opus*) session=opus ;;
  *fable*) session=fable ;;
  *sonnet*) session=sonnet ;;
  *haiku*) session=haiku ;;
  *) exit 0 ;;
esac

asked=$(printf '%s' "$input" | jq -r '.tool_input.model // empty' 2>/dev/null)
[ "$asked" = "$session" ] && exit 0

printf '%s' "$input" | jq -c --arg m "$session" --arg was "${asked:-(none)}" '
  {hookSpecificOutput: {
     hookEventName: "PreToolUse",
     updatedInput: (.tool_input + {model: $m}),
     additionalContext: ("agent-guard: subagent set to the session model (" + $m + "; requested " + $was + "). Subagents always run on the model the user chose for the session.")
  }}' 2>/dev/null || exit 0
exit 0
