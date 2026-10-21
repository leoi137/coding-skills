# _bin — pipeline v2 toolkit

Deterministic scripts the pipeline skills call. bash 3.2 + jq + gh; every one fails safe.
Design: `~/.claude/pipeline-v2-design/final-architecture.md`. State: `~/.claude/lanes/`.
Kill switch for every hook and slot: `LANES_OFF=1`.

| Script | Job |
|---|---|
| `lane` | `new <slug> [--ticket CB-n]` (worktree from fresh origin/main + env files + install + registry), `enter`, `here`, `set` (stage/PR/size), `list`, `conflicts` (overlap with other lanes and open PRs), `drop`, `gc` (dry run; `--apply` after the user approves), `claim`/`release`, `stats` |
| `lane-stats` | first-push-green baseline per author and size class (`lane stats`) |
| `heavy` | machine-wide slots `tsc` `test` `docker` `build` + memory admission; `heavy status`, `heavy classify '<cmd>'` |
| `gate` | `unit` after every unit · `push` before every push (run in background) · `impact` for the plan; writes `<worktree>/.lane/gate.json` |
| `ci-sigs` | failure signatures `kind\|scope\|detail` from a CI job log or a local gate log |
| `main-health` | is main green right now (newest settled CI run), failing signatures, 10-min cache |
| `ci-watch <pr>` | background poll of a PR's checks → classify failures ours / inherited / fixed-on-main / flaky |

## Hooks (`hooks/`)

| Hook | Event | Does |
|---|---|---|
| `heavy-guard.sh` | PreToolUse Bash | wraps heavy commands in `heavy` via `updatedInput` — **bypassPermissions and auto sessions only** (permission rules see the rewritten command) |
| `commit-guard.sh` | PreToolUse Bash | denies a commit / PR body carrying Co-Authored-By or "Generated with" |
| `agent-guard.sh` | PreToolUse Agent | sets every subagent's `model` to the session's model (read from the transcript), so subagents never silently run on Fable or a cheaper default; never denies |

Install (in `~/.claude/settings.json`, next to the ticket gate):

```json
{ "matcher": "Bash", "hooks": [
    { "type": "command", "command": "\"$HOME\"/.claude/skills/_bin/hooks/heavy-guard.sh", "timeout": 10 },
    { "type": "command", "command": "\"$HOME\"/.claude/skills/_bin/hooks/commit-guard.sh", "timeout": 10 } ] },
{ "matcher": "Agent", "hooks": [
    { "type": "command", "command": "\"$HOME\"/.claude/skills/_bin/hooks/agent-guard.sh", "timeout": 10 } ] }
```

## Claude Code mechanics (verified 2026-10-19, v2.1.303)

- **Entering a lane:** `EnterWorktree(path)` fails from the non-git launch dir ("current directory is not in a git repository"). Bash `cd <main checkout>` first (the cwd persists), then `EnterWorktree(path)`. Inside, Write/Edit to main-checkout paths is refused — lane artifacts live in `<worktree>/.lane/`.
- **CwdChanged** fires on a Bash `cd` (`old_cwd`, `new_cwd`), not on EnterWorktree/ExitWorktree. Every hook payload's `cwd` reflects the worktree after entry.
- **Subagents** share the parent's `session_id` in hook payloads, plus `agent_id` / `agent_type`. So ticket bindings by session cover subagents.
- **Agent hook:** `tool_name` is `Agent`; the model is `tool_input.model`, absent when omitted.
- **updatedInput** applies without a permission decision, and permission rules are checked against the *rewritten* input — so wrapping breaks allow rules in default-mode sessions. Auto mode's classifier ran a wrapped command without a prompt (2026-10-21), so heavy-guard rewrites in bypassPermissions and auto only. Several hooks returning updatedInput: last to finish wins.
- `CLAUDE_CODE_SESSION_ID` and `CLAUDE_PID` are set in every Bash call; `~/.claude/sessions/<pid>.json` gives the peer name.
