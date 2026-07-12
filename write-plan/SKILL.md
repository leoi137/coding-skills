---
name: write-plan
description: Produce a detailed, checklist-driven implementation plan for a feature. Use after /research-plan, or directly when the target is small and well understood. Writes a plans/TODO_<feature>.md with acceptance criteria + an ordered, markable checklist; does NOT write code.
---

# write-plan

**Read `~/.claude/skills/_shared/pipeline-contract.md` first** — it defines the TODO schema, artifact locations, the model floor, and the universal rules. Stage 2 of the pipeline. The plan artifact — not this conversation — is the contract that flows forward; write it so a fresh session can execute it with zero other context.

Goal: turn a research brief (or a clear ask) into an **ordered, verifiable, file-level plan** that `/execute-plan` can follow without rethinking architecture.

> **Model floor:** every `Agent` call runs Opus or Fable — never below Opus-class — passed explicitly. Full policy in the contract; fail closed if no frontier model is available.

## Inputs — and distrust them

- Prefer a `research/RESEARCH_<feature>.md` from `/research-plan`. Read it first; use its **Key-file map** instead of re-scouting.
- **Don't trust its citations — but verify cheaply.** Existence and wiring checks are deterministic: `grep` for the symbol, read only its surrounding region. **Never read whole files in the parent context to "make sure."** Anything needing *judgment* (which implementation is live, whether a contract allows the change) goes into the Plan subagent's brief, not parent reads.
- **Drift check (read-only):** the brief records the `branch@sha` it was derived from. If HEAD has moved since, spot-check (grep-level) that the load-bearing files/symbols still exist before leaning on them. Never commit.
- No research + non-trivial target? Say research is needed and offer to run `/research-plan` first — one sentence, then wait. For a small, local, well-understood change, plan directly from the request + a quick targeted read.

## How to run

1. **Goal — one sentence, observable.** What "done" looks like from outside. No speculative scope.

2. **Acceptance criteria.** 2–6 observable behaviors that prove the goal. These — not ticked boxes — define success; tests map to them.

3. **Delegate architecture to a `Plan` subagent** when the change crosses a boundary (UI/service/persistence/process/trust), changes persisted data or a public contract, has multiple viable approaches, or you can't confidently name the implementation path — *not* by file count. Brief it self-contained (paste, don't link): goal, acceptance criteria, constraints, relevant brief excerpts + Key-file map + snapshot, out-of-scope. Require: **"ground every named symbol by opening the file it lives in — never name a function from memory; mark anything you can't confirm `(unverified)`."** Ask for: approach (3–5 sentences), file/symbol change list, tests mapped to criteria, repo-native validation commands, risks, blocking decisions. For small/local changes, plan in the main thread.

4. **Write `<repo-root>/plans/TODO_<feature>.md`** (the contract's canonical home — never the repo root or a subproject dir) using the contract's **TODO schema** exactly: its section headings are how later stages find things.
   - **Phase on dependency boundaries, not item count.** A phase is a chunk that reaches a valid, testable state before the next starts.
   - **Don't add `(Review checkpoint)` markers.** `/execute-plan` runs every phase straight through to completion; there is no mid-plan pause to plan around. Review happens once at the end via `/review-plan`.
   - **Publish the `## Files` list to the session board** (contract §Session board) as this plan's claims, `Stage: write` — the earliest conflict signal other sessions get. If the claims overlap another plan's, name the collision in `## Open questions` (blocking if the same symbols) instead of proceeding silently.

5. **Resolve blocking decisions.** A safe, convention-consistent default → state it as an explicit assumption and proceed. No safe default → leave `Status: Blocked` and name the exact decision. Don't mark `Ready` while a blocking question remains.

6. **Hand back to the user.** The TODO is the only file you create. Show goal + acceptance criteria + checklist + any blocking questions, and ask for approval before `/execute-plan`. This is the pre-code gate — the cheapest place to catch a wrong plan.

## Rules

- **Name real, grounded symbols.** "Update the service layer" isn't a step; `updateGoalProgress()` in `src/services/strategyService.ts` is. Unconfirmed → mark `(unverified)`, never state flat.
- **Tests are first-class** and map to acceptance criteria — every behavior change gets a named test with an expected outcome.
- **No premature abstraction / legacy shims.** Three similar lines beat a speculative helper. **Exception:** compatibility behavior is fine with an identified consumer, migration, or rollout need — document its removal condition. (Projects with migrations or persisted data often genuinely need it — don't rule it out blindly.)
- **Keep the parent context lean.** Verification by grep + targeted region reads; whole-file understanding belongs to the Plan subagent.
- **Don't write code, don't commit.** Planning produces the TODO and nothing else.
