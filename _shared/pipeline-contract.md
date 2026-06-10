# Plan-pipeline contract

Shared contract for the five pipeline stages: `/research-plan → /write-plan → /execute-plan → /review-plan → /document-plan`, then `/commit-push`. Every stage reads this file on invocation. **The artifacts defined here — never conversation context — are the only contract between stages.**

## Fresh-session operability (universal)

Every stage must be fully operable from the artifacts alone — assume the conversation contains nothing. For long pipelines, prefer starting each stage in a fresh session (`/clear`): accuracy decays and tokens compound when one stage carries another's full context. If a stage needs something that isn't in an artifact, that's a bug in the previous stage — flag it, don't reconstruct from memory.

## Model floor (non-negotiable)

Every `Agent` call in every stage runs on the frontier tier — **Opus or Fable, never below Opus-class** (never Sonnet/Haiku). Default to the session model when that's Opus or Fable; if the session model is lower, pin `'opus'`. Pass the model **explicitly** on every call — omission can fall through to a cheaper agent-type default. Fail-closed: if no frontier model is available, stop and report that the stage can't proceed under policy.

## Universal rules

- **No commits, stashes, pushes, or destructive git** in any stage except `/commit-push`. Work lands in the uncommitted working tree for the user to read; the TODO checklist is the tracker.
- **Preserve other sessions' work.** The worktree is shared. Never revert or overwrite hunks another session produced; scope every operation to this plan's own files and symbols.
- **Write boundaries:** code edits only in `/execute-plan` (plus confirmed-defect fixes in `/review-plan`); doc edits only in `/document-plan`; research and planning produce artifacts only.

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
## Snapshot — branch@sha · research: research/RESEARCH_<feature>.md (or "none")
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
### Phase 2 (Review checkpoint): <chunk later phases build on>
## Validation — the repo's real commands
## Migration / rollout — or "none"
## Out of scope — explicitly excluded
## Open questions — tag (blocking) ones
```

`(Review checkpoint)` on a phase heading marks a boundary where `/execute-plan` pauses for a scoped `/review-plan` pass before later phases build on it. `/write-plan` marks them on risky boundaries (persistence/contract/security changes, or foundations several later phases depend on) — not on every phase.

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
