#!/usr/bin/env bash
# Status line: model · directory (branch) · Linear ticket.
# The ticket segment shows only in repos with .claude/linear.json, or when this session has a
# ticket bound somewhere while sitting outside the repo (e.g. a parent directory).
set -uo pipefail

. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)/lib.sh" 2>/dev/null || true

input=$(cat)
get() { printf '%s' "$input" | jq -r "$1 // empty" 2>/dev/null; }

session=$(get '.session_id')
dir=$(get '.workspace.current_dir')
[ -n "$dir" ] || dir=$(get '.cwd')
[ -n "$dir" ] || dir="$PWD"
model=$(get '.model.display_name')

out=""
[ -n "$model" ] && out="$model · "
out="$out$(basename "$dir")"
branch=$(git -C "$dir" symbolic-ref --quiet --short HEAD 2>/dev/null || git -C "$dir" rev-parse --short HEAD 2>/dev/null)
[ -n "$branch" ] && out="$out ($branch)"

ticket=""
state=$(ticket_state_file "$session" 2>/dev/null)
if found=$(ticket_find_root "$dir" 2>/dev/null); then
  root=$(ticket_canon "$found")
  case "$(ticket_binding_kind "$session" "$root")" in
    active) ticket=$(jq -r --arg r "$root" '.repos[$r].active | "\(.id)" + (if (.status // "") != "" then " · \(.status)" else "" end)' "$state" 2>/dev/null) ;;
    exempt) ticket="no ticket (exempt)" ;;
    *) ticket="no ticket" ;;
  esac
elif [ -n "$session" ] && [ -f "$state" ]; then
  ticket=$(jq -r '[.repos | to_entries[] | select(.value.active != null) | "\(.value.active.id)" + (if (.value.active.status // "") != "" then " · \(.value.active.status)" else "" end) + " (\(.key | split("/") | last))"] | join(", ")' "$state" 2>/dev/null)
fi

[ -n "$ticket" ] && out="$out · $ticket"
printf '%s\n' "$out"
