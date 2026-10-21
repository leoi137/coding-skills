---
name: ticket
description: Keep every change attached to a Linear ticket. Binds this session's work to an existing or new ticket, moves it through In Progress → In Review → Done at the real moments (first edit, PR opened, merge), and puts the ID where Linear's GitHub integration links it (commit subjects, PR title, `Fixes`/`Part of` in the PR body). Use when the Linear gate blocks an edit, commit or PR; when the user names a ticket (e.g. CB-123) or asks to switch tickets; when work drifts beyond the bound ticket; before opening a PR; when asked to create or file a ticket; or to reconcile Linear with GitHub (`/ticket sync`). Only active in repos that have `.claude/linear.json`.
---

# ticket

Goal: **nothing lands in a ticketed repo without a Linear ticket, and every ticket's status tells the truth.** The ticket is written *before* the work (never as a receipt afterwards), its status follows real events, and Linear's GitHub integration can link every commit and PR to it.

Three parts do this, and only the third is judgment:

| Part | Where | What it guarantees |
|---|---|---|
| Gate hook | `hooks/gate.sh` (PreToolUse) | No edit without a bound ticket (or an explicit "no ticket"); no `git commit` / `gh pr create` without a ticket ID |
| Context hook + status line | `hooks/prompt-context.sh`, `hooks/statusline.sh` | The bound ticket is visible every turn, to you and the user |
| This skill | you | Finding or creating the right ticket, noticing drift, moving status, writing the record |

Session state lives outside the repo, per session: `bin/ticket` (below). Linear itself is read and written only through the Linear MCP tools (`mcp__linear-server__*` here; any Linear MCP server works).

## 0. Read the repo's config

`.claude/linear.json` at the repo root (`bin/ticket config`). It names the team key(s), the status names, the required label groups, the gate's exempt paths, and **`gitAutomations`** — whether Linear's GitHub integration moves status by itself. When it is `false`, you make the In Review and Done moves described in §4. No config → the repo isn't ticketed; this skill does nothing there.

## 1. Resolve a ticket — when the gate fires, or before the first edit

Resolve once per piece of work, not per edit. Order:

1. **The ticket is already known — bind it, no question.** The user named it ("work on CB-345"), or the plan's `## Snapshot` line says `ticket: CB-n`. Verify with `get_issue`: right team, not Canceled or Duplicate. If it's **Done**, don't reopen it: propose a follow-up ticket related to it, unless the user says the work is unfinished. If it's **assigned to someone else**, ask before taking it.
2. **Otherwise collect candidates**, in this order of weight:
   - `bin/ticket recent`: what recent sessions in this repo were on. A ticket that spans several sessions continues here.
   - `list_issues` assignee `me`, state started or unstarted: the user's open work.
   - `list_issues` with `team` + a `query` of 2–3 distinctive words from the task: catches a teammate's ticket or an existing duplicate before you create one.
3. **Ask once, with `AskUserQuestion`.** Up to three options, best match first, and put the facts in each description: ID · title · status · assignee.
   - `Continue CB-n`: the strongest match. Add a second match only if it's close.
   - `New ticket`: put the full draft in the option's `preview` (title, project/milestone, labels, priority, the first lines of the body), so choosing it is also approving it.
   - `No ticket for this session`: for spikes and experiments. The user can type a ticket ID under "Other"; verify and bind it.
4. **Bind** (§2).

**Creating a ticket.** `save_issue` with:
- `team` from the config. `assignee: "me"`. `state`: the started status, because work starts now. For side findings (§3), use backlog.
- `title`: the observable outcome or the problem, in the team's voice: "The Build card lists the 360+ services and 487-investor lines", "Home arrival: step message renders outside the centre circle". Never "Fix bug" or "Update X".
- `labels`: exactly one child of every group in `requiredLabelGroups` (here **Type** and **Area**; the label descriptions say which fits), plus an optional **Surface** when the work is on one. Get the current names from `list_issue_labels` with `team` and `includeGroups: true`; don't guess them.
- `project` and, when one fits, `milestone`: the best fit among `list_projects` for the team (started or planned). If nothing clearly fits, leave it empty and say so in the preview. Don't force it.
- `priority`: 2 (High) when a user-facing path is broken or it's a launch item, otherwise 3. It's in the preview, so the user corrects it there.
- `description`, the contract:

```markdown
## Why this exists
<the problem or the opportunity, in one paragraph; link what it came from>

## What needs to be done
1. <concrete, checkable steps>

## Acceptance
- [ ] <observable behavior that proves it>

## Out of scope
- <what this ticket deliberately doesn't cover>
```

Add `## Watch out` only for real traps. Link related tickets with `relatedTo` / `parentId` / `blockedBy`, not only in prose.

## 2. Bind: this session is now on the ticket

```bash
~/.claude/skills/ticket/bin/ticket bind CB-123 --title "<title>" --status "<status>" --url "<url>" [--repo <repo root>]
```

- Pass `--repo` whenever your shell's cwd isn't inside the repo. The gate's message prints the exact line to run.
- If the ticket is in backlog or unstarted, move it to the started status (`save_issue` `state`) and assign it to `me` if unassigned. A ticket already In Review stays In Review: more commits on an open PR don't change its state.
- `ticket exempt "<reason>"` only when the user chose "no ticket". It lifts the edit gate for this session, but **anything committed still needs an ID**: history is always ticketed.
- `ticket status "<status>"` after every status change you make, so the status line stays true. It also writes the user's **team-update file** (§6).
- On the In Review and Done moves, add `--summary "<line>"`: one plain-English sentence of what the ticket delivers, for the user's end-of-day team update. Written for the team, not engineers: lead with the outcome, colons and commas for detail, no file names or jargon. E.g. `Notion works in actions: read pages, and save docs after you approve`. Once given it carries over to later moves, so Done needs it only if it changed.

## 3. While working: drift, switching, side findings

**Drift.** Before starting a change that isn't clearly inside the bound ticket's *What needs to be done* or *Acceptance*, ask one question: "Part of CB-n, or its own ticket?" Signals: a different surface or app than the ticket's; a bug unrelated to the ticket's problem; the user asking for something new mid-session. Edits the ticket's change needs in order to work are not drift. Don't ask about those.

**Switching.** A session isn't locked to one ticket. On a switch, `ticket bind` the new one; the previous one moves to the session's history with its status untouched, because unfinished work is still In Progress. If uncommitted changes belong to the old ticket, say so: they go in their own commits, with its ID (§4).

**Long tickets.** A ticket that outlives a session needs nothing special. The next session's gate offers it first ("recent"), and one click resumes it.

**Side findings** (bugs or debt noticed along the way). Don't write them into the bound ticket's description, and don't interrupt the work for each one. Collect them, then at the next natural pause (before committing is the usual one) propose them to the user as one batch. Each one approved becomes its own ticket in the backlog state, `relatedTo` the bound ticket, with the contract body.

**Description vs comments.** The description is the contract; change it only when the scope itself changes, and leave a comment saying what changed and why. Progress, results and hand-offs go in **comments** (`save_comment`), never appended to the description.

## 4. Commit, PR, review, done

**Commits.** Every commit subject ends with its ticket ID: `fix(home): the arrival line sits inside the circle (CB-346)`. One commit never mixes tickets. `/commit-push` groups by ticket. The gate rejects a commit without an ID, and the `NO_TICKET=1` prefix is only for when the user said so explicitly.

**PR.** Draft PRs don't mean review. When the PR is opened for review:
- **Title:** `<subject> (CB-n)`.
- **Body, first line:** `Fixes CB-n` (merging closes it) or `Part of CB-n` (links it without closing it, for one of several PRs). A PR covering several tickets uses `Fixes CB-301, CB-300`. Magic words in the body are what Linear reads; a bare ID in prose doesn't link.
- Then check the ticket (`get_issue`): the PR should show as an attachment. If `gitAutomations` is `false`, or it's `true` but the status didn't move, set the review status yourself and run `ticket status`.
- Post **one** comment on the ticket: the PR link; what changed (3–6 bullets); how it was verified (exact commands and results, plus what was *not* verified, e.g. "not checked in a browser"); what's left.

**Done** means merged. Never mark a ticket Done on push or on PR open. With automations on, Linear does it at merge. With them off, set Done only after confirming the merge yourself (`gh pr view <n> --json state,mergedAt` → `MERGED`).

## 5. `/ticket sync`: reconcile Linear with GitHub

Run it when the user asks, or when you notice drift like a merged PR whose ticket still says In Review. For the user's started tickets (`list_issues` assignee `me`), check each linked PR (`get_issue` attachments, or `gh pr list --search "CB-n"`). Propose every move in a single table (ticket · now · should be · evidence) and apply what the user approves. Typical moves:
- Merged → Done.
- An open PR that isn't a draft → In Review.
- No commits and no PR for a long time → ask whether it's still in progress.
- Open items listed in a description → offer them as tickets.

After each move you apply here, run `ticket log CB-n --status "<new status>" --title "<title>" --summary "<line>"` (the ticket isn't bound, so `ticket status` can't record it).

## 6. The team-update file

Every `bind`, `status` and `log` appends to `~/.claude/state/ticket/updates.jsonl` and rebuilds `<updatesDir>/<YYYY-MM-DD>.md` (`updatesDir` in `.claude/linear.json`; default `<repo>/../team-updates`): every ticket moved that day under its latest status, as **Completed / In review / In progress**, with its summary (or its title if none was given). The user pastes it as their daily team update. `ticket update [--date D]` rebuilds and prints a day. Never hand-edit the generated file; correct a line by logging the move again with a better `--summary`.

## Rules

- **Ticket first.** Never create a ticket already Done to record work after the fact. If work happened without one, create it in its real state and say so in a comment.
- **Never mark Done** without a verified merge. **Never Cancel a duplicate**: set `duplicateOf` (the Duplicate status) so the link survives.
- **Labels describe the kind of work, never a date or a release.** Dates belong in milestones, cycles or releases.
- **One question per resolution.** The gate, drift and side findings each ask at most once, with a recommended default. Never several rounds.
- **Linear is shared.** Other people see every write. Creating, re-assigning, re-scoping and closing happen only after the user approves (the resolution question counts). Binding, the started move on a ticket the user chose, and the review move when their PR opens are part of the agreed flow.
- **Subagents and background runs can't ask.** If the gate blocks you there, stop and report that the work needs a ticket; don't exempt yourself.

## Setup: a new repo or a new machine

See `references/setup.md`: the `linear.json` template, the three settings entries (two hooks and the status line), and how to disable the gate.
