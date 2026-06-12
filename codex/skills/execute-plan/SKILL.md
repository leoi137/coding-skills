---
name: execute-plan
description: Implement a ready TODO plan from plans/ as ordered, verifiable units. Use after write-plan approval or to resume an In progress plan. Updates checklist and Changed manifest as work proceeds; never commits.
---

# execute-plan

Codex adapter for the plan-pipeline execution stage. Preserve the artifact
contract used by the Claude Code skills, but use Codex-native mechanics.

## Shared contract

Read `~/.claude/skills/_shared/pipeline-contract.md` first. It defines the
TODO schema, Changed manifest, Result section, and universal pipeline rules.
If this repo is installed somewhere else, locate the same file in the
`coding-skills` clone and use that copy.

## Codex translation

- Treat the contract's Opus/Fable model floor as Claude-specific. In Codex, use
  deterministic tools for retrieval and validation. Use Codex subagents only
  for judgment-heavy questions, not simple symbol lookup.
- Treat `/execute-plan` as this Codex skill invocation (`$execute-plan` or
  selection through `/skills`).
- The TODO checklist and Changed manifest are the recovery state. Do not rely on
  prior conversation context.

## Preconditions

- A `plans/TODO_<feature>.md` exists with `Status: Ready`, or `Status: In
  progress` when resuming.
- There are no open blocking decisions.
- The user has approved executing the plan.

## Workflow

1. Read the whole plan. If ambiguity changes behavior, architecture, data,
   contracts, security, or scope, ask one consolidated question and stop.
2. Run a read-only drift check against the plan snapshot. If the plan is
   materially stale, mark it blocked and report the mismatch.
3. Capture baseline branch/sha, dirty worktree, and pre-existing pass/fail state
   of the plan's validation commands.
4. Set `Status: In progress` when starting.
5. Work one coherent unit at a time: ground symbols at point of use, make the
   smallest complete change, add or update tests from the acceptance criterion,
   observe red-before-green when practical, validate, inspect the scoped diff,
   tick only passing checklist items, and update `## Changed manifest` in the
   same edit.
6. At a `(Review checkpoint)` phase boundary, stop and tell the user the slice
   is ready for `$review-plan`.
7. When all checklist items are ticked, re-check acceptance criteria, run the
   full relevant validation, verify the manifest is exact, and append `## Result`
   with exact command outcomes and any deviations.

## Rules

- Do not commit, stash, push, deploy, run destructive git, or make unapproved
  external side effects.
- Preserve other sessions' work. Never revert or overwrite pre-existing changes
  outside this plan's scope.
- Do not use `--no-verify`, suppress errors, weaken assertions, or disable tests
  to force green.
- If reality diverges locally, update the plan line and continue. If divergence
  changes architecture, acceptance criteria, public contracts, persistence,
  security, rollout, or scope, mark the plan `Blocked` and stop.
