# ticket — setup

## Turn a repo on

Create `<repo-root>/.claude/linear.json`. Its presence is the switch: the gate, the status line segment and the skill do nothing in a repo without it.

```json
{
  "workspace": "<linear url key>",
  "team": { "key": "ENG", "name": "<team name>" },
  "teamKeys": ["ENG"],
  "statuses": {
    "backlog": "Backlog", "todo": "Todo", "started": "In Progress",
    "review": "In Review", "done": "Done", "canceled": "Canceled", "duplicate": "Duplicate"
  },
  "gitAutomations": false,
  "requiredLabelGroups": ["Type"],
  "optionalLabelGroups": [],
  "exemptPaths": ["plans/SESSIONS.md", "research/**", ".claude/linear.json", ".claude/settings.local.json"]
}
```

- **`teamKeys`**: every issue prefix a commit or PR in this repo may reference.
- **`statuses`**: the team's own names for each role (`list_issue_statuses`).
- **`gitAutomations`**: `true` only once you've seen Linear move an issue by itself when a linked PR opened and when one merged. Until then the skill makes those moves.
- **`requiredLabelGroups`**: label groups every new issue must carry one child of (`list_issue_labels` with `includeGroups: true`).
- **`exemptPaths`**: repo-relative globs the edit gate ignores. `**` and `*` both match across `/`. Keep this list short: planning and research artifacts, and the gate's own config.

Is the repo shared and `.claude/` committed? Then commit this file, and teammates who install the hooks get the same gate. Otherwise it stays personal to the checkout.

## Install the hooks and status line (once per machine)

Merge these into `~/.claude/settings.json` without replacing any existing `hooks` arrays or an existing `statusLine`:

```json
{
  "hooks": {
    "PreToolUse": [
      { "matcher": "Edit|Write|MultiEdit|NotebookEdit",
        "hooks": [{ "type": "command", "command": "\"$HOME\"/.claude/skills/ticket/hooks/gate.sh", "timeout": 10 }] },
      { "matcher": "Bash",
        "hooks": [{ "type": "command", "command": "\"$HOME\"/.claude/skills/ticket/hooks/gate.sh", "timeout": 10 }] }
    ],
    "UserPromptSubmit": [
      { "hooks": [{ "type": "command", "command": "\"$HOME\"/.claude/skills/ticket/hooks/prompt-context.sh", "timeout": 5 }] }
    ]
  },
  "statusLine": { "type": "command", "command": "\"$HOME\"/.claude/skills/ticket/hooks/statusline.sh" }
}
```

Requirements: `jq` and `git` on PATH. The scripts are bash-3.2 compatible (stock macOS). Session state goes to `~/.claude/state/ticket/` (override with `TICKET_STATE_DIR`).

## Verify

```bash
# Expect "deny" for an unbound session, then "allow" after a bind.
R=<repo root>
jq -nc --arg p "$R/src/x.ts" '{session_id:"probe",cwd:"/tmp",tool_name:"Edit",tool_input:{file_path:$p}}' \
  | ~/.claude/skills/ticket/hooks/gate.sh | jq -r .hookSpecificOutput.permissionDecision
~/.claude/skills/ticket/bin/ticket bind ENG-1 --repo "$R" --session probe
jq -nc --arg p "$R/src/x.ts" '{session_id:"probe",cwd:"/tmp",tool_name:"Edit",tool_input:{file_path:$p}}' \
  | ~/.claude/skills/ticket/hooks/gate.sh; echo "exit $? (no output = allow)"
rm ~/.claude/state/ticket/probe.json
```

## Turn it off

- **One repo:** delete or rename its `.claude/linear.json`.
- **One session:** answer "No ticket for this session" (`ticket exempt`). Commits still need an ID.
- **One commit or PR, with the user's explicit OK:** prefix the command with `NO_TICKET=1`.
- **Everywhere:** remove the three entries above from `~/.claude/settings.json` (or review them in `/hooks`).

Codex reads this skill too, but it has no hooks. There the skill still guides the flow; nothing enforces it.
