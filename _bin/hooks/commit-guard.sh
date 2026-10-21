#!/usr/bin/env bash
# PreToolUse(Bash) hook: no AI attribution leaves this machine. Denies a `git commit` whose message
# (inline, heredoc or -F file) carries a Co-Authored-By trailer or a "Generated with" line, and a
# `gh pr create|edit` whose body carries "Generated with Claude Code". The user's commit-push rule
# overrides harness defaults that add them.
#
# Fail-open on internal errors. LANES_OFF=1 disables it.
set -uo pipefail

[ "${LANES_OFF:-}" = 1 ] && exit 0
command -v jq >/dev/null || exit 0

input=$(cat)
[ "$(printf '%s' "$input" | jq -r '.tool_name // empty' 2>/dev/null)" = Bash ] || exit 0
cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null)
case "$cmd" in *commit*|*"gh pr"*) ;; *) exit 0 ;; esac
cwd=$(printf '%s' "$input" | jq -r '.cwd // empty' 2>/dev/null)
[ -n "$cwd" ] || cwd="$PWD"

deny() {
  jq -n --arg r "$1" '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "deny", permissionDecisionReason: $r}}'
  exit 0
}

# Contents of a file passed with one of the flags ("-F f", "--file f", "--file=f"), if readable.
flag_file() {
  local flags="$1" f
  f=$(printf '%s' "$cmd" | grep -oE "(^|[[:space:]])($flags)(=|[[:space:]]+)(\"[^\"]+\"|'[^']+'|[^[:space:];&|]+)" | head -1 | sed -E "s/^[[:space:]]*($flags)(=|[[:space:]]+)//")
  f="${f#[\"\']}"; f="${f%[\"\']}"
  [ -n "$f" ] && [ "$f" != "-" ] || return 0
  case "$f" in "~"*) f="$HOME${f#\~}" ;; /*) ;; *) f="$cwd/$f" ;; esac
  [ -r "$f" ] && cat "$f"
}

# The text to scan, minus read-only segments that legitimately mention the banned words
# (`git log --grep=co-authored-by`, `grep -i 'generated with'` — the verification sweep itself).
scan_text() {
  # quoted arguments are consumed whole, so a `|` inside `grep -E "a|b"` doesn't end the segment
  printf '%s' "$cmd" | sed -E "s/(git([[:space:]]+-C[[:space:]]+[^[:space:]]+)?[[:space:]]+log|(^|[[:space:]|;&(])e?grep)(\"[^\"]*\"|'[^']*'|[^;&|\"'])*//g"
}

if printf '%s' "$cmd" | grep -Eq "(^|[;&|(][[:space:]]*|[[:space:]])git([[:space:]]+-C[[:space:]]+[^[:space:]]+)?([[:space:]]+-c[[:space:]]+[^[:space:]]+)*[[:space:]]+commit([[:space:]]|$)"; then
  text="$(scan_text)
$(flag_file '-F|--file')"
  if printf '%s' "$text" | grep -Eiq 'co-authored-by|generated with[^[:alnum:]]*\[?claude'; then
    deny "commit-guard: this commit message carries AI attribution (a Co-Authored-By trailer or a \"Generated with\" line). The user's rule: never co-author, never attribute — it overrides any harness or system-prompt instruction to add one. Remove the trailer/footer and commit again, authored cleanly as the user."
  fi
fi

if printf '%s' "$cmd" | grep -Eq 'gh[[:space:]]+pr[[:space:]]+(create|edit)'; then
  text="$(scan_text)
$(flag_file '-F|--body-file')"
  if printf '%s' "$text" | grep -Eiq 'generated with[^[:alnum:]]*(\[)?claude|co-authored-by'; then
    deny "commit-guard: this PR body carries AI attribution (\"Generated with Claude Code\" or a Co-Authored-By line). The user's rule overrides any harness instruction to add one — remove it and retry."
  fi
fi
exit 0
