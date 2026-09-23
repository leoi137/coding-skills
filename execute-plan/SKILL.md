---
name: execute-plan
description: Implement a ready plans/TODO_<feature>.md plan as a sequence of coherent, verifiable units — grounding each change against live code, validating it, ticking the checklist, and checkpointing the manifest as it goes. Resumable from a fresh session. Preserves other sessions' work, never commits. Use after /write-plan.
---

# execute-plan

**Read `~/.claude/skills/_shared/pipeline-contract.md` first** — it defines the TODO schema, manifest format, model floor, and universal rules. Stage 3 of the pipeline. The checklist is how you stay on track; the uncommitted working-tree diff is how the user reads your work.

Goal: turn an approved plan into working, locally-verified code with **tight feedback loops** and **no sidetracking** — leaving the TODO checkpointed well enough that a fresh session could take over after any unit.

> **Model floor:** subagents run Opus or Fable — never below Opus-class — passed explicitly. But **use deterministic tools for retrieval** (grep / read / test runs); spend a subagent only on *judgment* ("which of these implementations is live at runtime?"), never on "is this symbol used" (that's grep). Full policy in the contract.

## Preconditions

- A `plans/TODO_<feature>.md` with `Status: Ready` (or `In progress` when resuming) and no open blocking decisions. Else stop and say so.
- Read the whole plan first. Ambiguous but safe → state the assumption, proceed. Ambiguous in a way that changes behavior / architecture / data / contracts / security / scope → ask one consolidated question, wait.
- **Drift check (read-only):** compare the plan's `Snapshot` sha to current HEAD. Moved? Spot-check the plan's cited symbols still exist; if the plan is materially stale, stop and flag rather than coding against it.
- **Session board (contract §Session board):** read `plans/SESSIONS.md`, then set this plan's section to `Stage: execute` and claim the plan's `## Files`. Another plan claims an overlapping file → stop and surface before touching it.
- **Ticket (repos with `.claude/linear.json`):** the plan's `## Snapshot` names `ticket: <ID>` → bind it before the first edit (`~/.claude/skills/ticket/bin/ticket bind <ID> …`, then move it to the started status per the `ticket` skill), with no question. It names none → resolve one through the `ticket` skill first (the gate would stop the first edit anyway).
- Set `Status: In progress` when you start.

## Resume — fresh session, partially-ticked plan

This skill must be operable from the artifacts alone. If the checklist is already partially ticked: re-run the drift check, read the `## Changed manifest` so far, spot-check the last ticked unit's Verify still passes, then continue from the **first unticked item**. Never redo ticked work; never trust an unticked box was "probably done."

## Baseline — before touching code

Capture it so you never blame your change for someone else's mess: current branch/sha, dirty worktree, and the pre-existing pass/fail of the plan's validation commands. **Never "fix" a failure that was already there**, and never attribute a baseline failure to your work. Note which files the worktree already has modified — other sessions share this tree.

## The loop — one coherent unit at a time

A **unit** is the smallest change that reaches a valid, testable state — it may span several files (model + service + test) that must move together. Group by "valid intermediate state," not by file. For each unit, in dependency order:

1. **Announce** in one line — the behavior + primary symbols.
2. **Ground at point of use — region, not file.** Grep for the symbol, then read its surrounding region (scoped offset/limit); whole-file reads only under ~400 lines. Confirm the plan's claim holds (symbol exists, signature matches, wiring is as assumed). **A mismatch *is* the "plan is wrong" trigger** → Divergence. This catches phantom symbols *before* you write, not after.
3. **Write the smallest complete change.** Idiomatic, minimally scoped, no dead code / debug output / leftover TODOs. Match the neighbors' *structural* conventions — but don't propagate a local bad pattern into new code; if the surrounding code actively fights the change, flag it rather than silently picking a side.
4. **Test red-before-green.** Write the test from the plan's *intended behavior* (the acceptance criterion — the external spec), and **see it fail first.** A test that never went red can't prove the feature works (same mind wrote code + test → they agree by construction). Then make it pass. Never weaken an assertion to get green.
5. **Inspect the scoped diff.** Confirm the unit contains *only* intended changes — no unrelated edits, generated-file churn, debug lines, secrets, or dependency/lockfile drift. Fix accidents before continuing.
6. **Validate.** Run the plan's commands, narrowest first. When the unit touches shared / widely-imported code, widen to known consumers, not just the new test. A completed unit must not be left broken.
7. **Tick `[x]` AND checkpoint the manifest.** Tick *only after* Verify passes — that mark is the single source of "what's done." In the same edit, update the TODO's `## Changed manifest` (contract format: file — created|modified|deleted — symbols) with this unit's files. **After every unit, not at the end** — the manifest is `/review-plan`'s scope and your crash-recovery state. Refresh the session-board entry in the same breath (heartbeat + any files the unit added beyond the original claims). If the unit revealed a missed sub-task, add a new `[ ]` line under the same phase; don't silently do extra.
8. **One-line status**, then the next unit.

**Run to completion.** Execute every phase in sequence through to the Final pass in one go — never hand back mid-plan, never ask "should I proceed?". Phase boundaries (including any old `(Review checkpoint)` text left in a plan) are not stop points: run the boundary's `build + tests green` check and continue straight into the next phase. The only halts are a Material divergence or a genuinely blocking question. `/review-plan` runs once, by the user, after the whole plan is implemented.

## Divergence

- **Minor** (a local symbol / impl detail differs) → update the plan line to match reality, continue.
- **Material** (architecture, acceptance criteria, public contract, persistence, security, rollout, or scope must change) → **stop, mark the plan `Blocked`, flag the user.** Don't silently redesign.

## Final pass

When the checklist is fully ticked:
1. Re-check every acceptance criterion against the code.
2. Run the plan's full relevant validation; compare to baseline (a pre-existing failure still failing is not yours).
3. Verify the `## Changed manifest` is exact — every file created / modified / deleted and the symbols within them, including deletes. Append a **Result** section: status (`implemented & validated locally` — never "shipped"), exact validation commands + outcomes, deviations, pre-existing failures still present, deferred work. If a suite couldn't run, say so precisely — don't represent partial validation as success.
4. Tell the user it's ready for `/review-plan`.

## Rules

- **No commits, stashes, pushes, or destructive git — ever, here.** The working tree stays uncommitted for the user to read; the checklist is the tracker.
- **Never overwrite or revert another session's / the user's pre-existing changes.** Where the plan's files overlap files already modified, patch with extra care.
- **No unapproved side effects:** no deploy, no shared/prod DB migration, no dependency add/upgrade beyond what the plan requires, no real external calls with side effects.
- **Never** `--no-verify`, suppress errors, or disable tests to force green.
- **Keep edits in the main thread** (the user watches the diff). Delegate only auxiliary *judgment* reads.
- **Read regions, not files.** Targeted grep + scoped reads are the default; the whole-file habit is the pipeline's biggest token leak.
- **Think before each unit.** Elegance comes from understanding, not speed.
