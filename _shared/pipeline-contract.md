# Plan-pipeline contract

Shared contract for the five pipeline stages: `/research-plan → /write-plan → /execute-plan → /review-plan → /document-plan`, then `/commit-push`. Every stage reads this file on invocation. **The artifacts defined here — never conversation context — are the only contract between stages.**

## Fresh-session operability (universal)

Every stage must be fully operable from the artifacts alone — assume the conversation contains nothing. For long pipelines, prefer starting each stage in a fresh session (`/clear`): accuracy decays and tokens compound when one stage carries another's full context. If a stage needs something that isn't in an artifact, that's a bug in the previous stage — flag it, don't reconstruct from memory.

## Model floor (non-negotiable)

Every `Agent` call in every stage runs on the frontier tier — **Opus or Fable, never below Opus-class** (never Sonnet/Haiku). Default to the session model when that's Opus or Fable; if the session model is lower, pin `'opus'`. Pass the model **explicitly** on every call — omission can fall through to a cheaper agent-type default. Fail-closed: if no frontier model is available, stop and report that the stage can't proceed under policy.

## Universal rules

- **No commits, stashes, pushes, or destructive git** in any stage except `/commit-push`. Work lands in the uncommitted working tree for the user to read; the TODO checklist is the tracker.
- **Preserve other sessions' work.** The worktree is shared. Never revert or overwrite hunks another session produced; scope every operation to this plan's own files and symbols.
- **Check the session board** (below) at the start of every stage, and keep your plan's entry current. It is how sessions see each other *before* colliding instead of after.
- **Write boundaries:** code edits only in `/execute-plan` (plus confirmed-defect fixes in `/review-plan`); doc edits only in `/document-plan`; research and planning produce artifacts only.

## Session board — multi-session coordination

Multiple sessions run against the same repo at once. The board makes each session's intent visible to all the others: **`<repo-root>/plans/SESSIONS.md`** — one board per repo, live coordination state, **never committed** (`/commit-push` always excludes it; add it to `.gitignore` if the repo hasn't already).

One `## <feature>` section per plan in flight:

```markdown
# Session board — live, do not commit
<!-- One section per plan. Edit ONLY your own section. -->

## <feature>
- Plan: plans/TODO_<feature>.md
- Stage: research | write | execute | review | document | commit
- Heartbeat: <UTC from `date -u +"%Y-%m-%d %H:%M"`>
- Claimed files:
  - `path/a.ts`
  - `path/b.ts`
```

Protocol — every stage, right after reading this contract:

1. **Read the board.** Missing → create it from the template above. Claims come from the plan's `## Files` section (from `/write-plan` onward) and are kept in sync with the `## Changed manifest` as execution reveals new files.
2. **Conflict check.** Intersect the files this stage will touch with every *other* section's claims. Overlap → never touch the shared file silently: scope to your own symbols/hunks where the stage's shared-file rules allow it, otherwise stop and surface ("`<other-feature>` claims `path` — serialize or re-scope?"). A claim means *ask before touching*, not *never touch*.
3. **Register.** Add or update **your plan's own section only** — stage, heartbeat, claims. Re-read the board immediately before editing, and edit by section (anchored Edit) — **never rewrite the whole file**, that's how a concurrent session's update gets clobbered. Refresh the heartbeat at every stage start/end and at every `/execute-plan` unit checkpoint.
4. **Release.** `/commit-push` deletes the plan's section when its commits land (alongside the TODO/RESEARCH cleanup offer). A section whose heartbeat is >24h old with no matching dirty files in the worktree is stale — confirm with the user, then prune.

The board is coordination state, not documentation: it records *intent and ownership*, nothing else. The TODO stays the source of truth for progress; the board only answers "who is touching what, right now."

## Linear ticket — repos with `.claude/linear.json`

In a ticketed repo every plan belongs to one Linear ticket, and the `ticket` skill (`~/.claude/skills/ticket/SKILL.md`) owns the Linear side. Its hooks enforce it: no edit without a ticket bound to the session, and no commit or PR without the ID.

- `/write-plan` resolves the ticket, existing or new, and records it on the `## Snapshot` line (`ticket: CB-123`). Writing the plan is the commitment.
- `/execute-plan` binds the plan's ticket at start (`ticket bind`), with no question.
- `/commit-push` ends every commit subject with ` (<ID>)` and never mixes two tickets in one commit.
- Research is pre-commitment. `research/` and the session board are exempt from the gate.

Repos without the config: ignore this section.

## Artifact locations & naming

Defaults — a repo's CLAUDE.md may override, but there is exactly **one home per artifact type per repo**:

- Research brief → `<repo-root>/research/RESEARCH_<feature>.md`
- Plan → `<repo-root>/plans/TODO_<feature>.md`

Never write a pipeline artifact anywhere else — not the repo root, not a subproject dir. Scattered artifacts get read as current truth by other agents long after they go stale.

**Lifecycle — artifacts are ephemeral; git history is the archive.** When the work ships, `/commit-push` offers to delete the plan's TODO + RESEARCH files as part of the shipping commits. A plan stamped "Completed" still sitting in the tree is sprawl, not documentation.

## TODO schema (canonical)

`/write-plan` creates it; later stages append. Section headings are load-bearing — stages locate them by exact name.

```markdown
# <Feature> — Implementation Plan
## Status — Ready | Blocked | In progress | Done
## Snapshot — branch@sha · research: research/RESEARCH_<feature>.md (or "none") · ticket: <ID> (or "none")
## Goal — one sentence, observable from outside
## Acceptance criteria
- [ ] <observable behavior>
## Executive summary — 3–5 sentences: strategy and boundaries, not steps
## Files (create / modify / delete)
- `path` — create|modify|delete — what & why
## Checklist — ordered, phased
### Phase 1: <coherent, independently-valid chunk>
- [ ] Step — Files/symbols: `sym in path` — Depends on: <step|none> — Verify: <test/command/observable>
- [ ] (phase boundary) build + existing tests green
### Phase 2: <chunk later phases build on>
## Validation — the repo's real commands
## Migration / rollout — or "none"
## Out of scope — explicitly excluded
## Open questions — tag (blocking) ones
```

`/execute-plan` runs every phase in sequence straight through to completion — there are no mid-plan review stops. `/review-plan` runs once, after the full plan is implemented, scoped to the `## Changed manifest`.

**Appended as the pipeline runs:**

- `## Changed manifest` — **`/execute-plan` updates this after every unit, not at the end** (interruption-safe; it is `/review-plan`'s scope). One line per file: `path` — created|modified|deleted — symbols: `a, b, c`. Deletes included.
- `## Result` — execute's final status (`implemented & validated locally`, never "shipped"), exact validation commands + outcomes vs baseline, deviations, deferred work.
- `## Review` — verdict, fixes applied, decisions surfaced.
- `## Docs` — docs updated + which invariant changed, drift closed.

**Status ownership:** `/write-plan` sets `Ready`/`Blocked` · `/execute-plan` sets `In progress` on start · `/document-plan` sets `Done` at the end.

## Research brief schema (canonical)

Target & scope · Snapshot (branch@sha) · Architecture (5–8 load-bearing facts) · Key files & symbols (grouped by concern) · End-to-end data/control flow (numbered) · State, auth & failure boundaries · Existing tests · Risks, contradictions & unknowns · Doc drift (existing-doc statements the code contradicts — closed later by `/document-plan`) · Coverage (per angle: covered / partial / not investigated) · **Key-file map** (compact appendix: `path — one-line role`, so later stages never re-scout) · Next step.

Under ~300 lines. Cite symbols (`handleFoo in bar.ts`), not raw line numbers — lines drift and get hallucinated. Mark every claim **observed / inferred / conflicting / unverified**; never present inference as fact.

## Finding format (review)

Every reviewer finding, ≤150 words, no narrative: **severity** (blocker/high/med/low) · **confidence** (confirmed-by-reading / suspected) · **location** (symbol + hunk, not a raw line) · **scenario** · **impact** · **fix direction**.
