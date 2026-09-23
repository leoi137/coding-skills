#!/usr/bin/env bash
# UserPromptSubmit hook for the ticket skill: while a ticket is bound, remind the model which one,
# so work that drifts outside it gets noticed before the next edit rather than at commit time.
# Silent when nothing is bound. Never fails the prompt.
set -uo pipefail

. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)/lib.sh" 2>/dev/null || exit 0
command -v jq >/dev/null || exit 0

input=$(cat)
session=$(printf '%s' "$input" | jq -r '.session_id // empty' 2>/dev/null)
[ -n "$session" ] || exit 0
state=$(ticket_state_file "$session")
[ -f "$state" ] || exit 0

lines=$(jq -r '
  .repos | to_entries[]
  | select(.value.active != null)
  | "- \(.key | split("/") | last): \(.value.active.id) — \(.value.active.title // "") [\(.value.active.status // "")]"' "$state" 2>/dev/null)
[ -n "$lines" ] || exit 0

ctx="Linear ticket bound to this session:
$lines
If this request is outside that ticket's scope, ask the user whether it belongs to it or needs its own ticket before editing (ticket skill → Drift and switching). Commits end with the ticket ID."

jq -n --arg c "$ctx" '{hookSpecificOutput: {hookEventName: "UserPromptSubmit", additionalContext: $c}}'
exit 0
