---
name: review-plan
description: Independently review and fix the changes made by a plan, scoped to the plan's Changed manifest or a Review checkpoint. Use after execute-plan. Appends a Review verdict to the TODO; never commits.
---

# review-plan

Codex adapter for the plan-pipeline review stage. Preserve the artifact contract
used by the Claude Code skills, but use Codex-native mechanics.

## Shared contract

Read `~/.claude/skills/_shared/pipeline-contract.md` first. It defines the
Changed manifest, finding format, Review section, and universal pipeline rules.
If this repo is installed somewhere else, locate the same file in the
`coding-skills` clone and use that copy.

## Codex translation

- Treat the contract's Opus/Fable model floor as Claude-specific. In Codex,
  prefer high reasoning for reviewer subagents, but do not fail solely because
  Opus/Fable are unavailable.
- Translate Claude reviewer `Agent` calls to Codex subagents. If subagents are
  unavailable, perform the three reviewer passes separately in the main session
  and keep the notes scoped.
- Treat `/review-plan` as this Codex skill invocation (`$review-plan` or
  selection through `/skills`).

## Scope

Review only the plan's `## Changed manifest` intersected with the live
working-tree diff. In checkpoint mode, review only the manifest-so-far for the
completed phases. If shared-file hunks cannot be cleanly separated from another
session's work, return `Blocked: target ambiguous`.

## Workflow

1. Read the plan's goal, acceptance criteria, Changed manifest, Result, and
   relevant research brief if present.
2. Run the plan's validation commands once and record exact results. Compare
   them to execute's claimed Result.
3. Use three independent review passes, preferably parallel Codex subagents:
   correctness vs real goal, regressions and contracts, and quality/simplicity
   and scope.
4. Require findings to use the shared contract format: severity, confidence,
   location by symbol/hunk, scenario, impact, and fix direction.
5. Adjudicate findings. Confirm blocker/high issues with targeted reads.
6. Fix confirmed code-level defects in place, rerun the relevant validation,
   and use one independent re-check for blocker/high fixes when subagents are
   available.
7. Append `## Review` to the TODO with one verdict: `Approved`, `Approved
   (fixed)`, `Changes required`, or `Blocked: insufficient evidence`.

## Rules

- Stay inside manifest scope. Do not review or fix unrelated dirty worktree
  changes.
- Do not commit, stash, push, run formatters/generators that mutate unrelated
  files, or use destructive git.
- Do not trust ticked boxes or passing tests without code evidence.
- Fix confirmed defects; surface product, architecture, scope, or ambiguous
  ownership decisions instead of auto-deciding them.
