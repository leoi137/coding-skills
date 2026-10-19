#!/usr/bin/env bash
# PreToolUse(Agent) hook: the pipeline's model floor. Every subagent runs on Opus or Fable, passed
# explicitly — a call with no `model` silently inherits whatever the agent type defaults to.
# Forks are exempt (they always run on the parent's model).
#
# Verified 2026-10-19 on 2.1.303: tool_name is "Agent", the field is tool_input.model, absent when
# the caller omits it; subagent hook calls carry the parent's session_id plus agent_id/agent_type.
#
# Fail-open on internal errors. LANES_OFF=1 disables it.
set -uo pipefail

[ "${LANES_OFF:-}" = 1 ] && exit 0
command -v jq >/dev/null || exit 0

input=$(cat)
case "$(printf '%s' "$input" | jq -r '.tool_name // empty' 2>/dev/null)" in Agent|Task) ;; *) exit 0 ;; esac
type=$(printf '%s' "$input" | jq -r '.tool_input.subagent_type // empty' 2>/dev/null)
[ "$type" = fork ] && exit 0
model=$(printf '%s' "$input" | jq -r '.tool_input.model // empty' 2>/dev/null | tr '[:upper:]' '[:lower:]')

case "$model" in
  opus|fable|claude-opus-*|claude-fable-*) exit 0 ;;
esac

if [ -z "$model" ]; then why="passes no model"; else why="asks for model \"$model\""; fi
jq -n --arg r "agent-guard: this Agent call $why. Model floor: every subagent runs on Opus or Fable, passed explicitly — add model: \"opus\" (or \"fable\" for an independent second-opinion reviewer) and retry. Forks are exempt." \
  '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "deny", permissionDecisionReason: $r}}'
exit 0
