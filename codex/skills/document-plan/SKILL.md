---
name: document-plan
description: Update project documentation to match the approved changes made by a plan. Use after review-plan approves. Edits only docs whose recorded invariants changed, appends Docs, and marks the TODO Done; never commits.
---

# document-plan

Codex adapter for the plan-pipeline documentation stage. Preserve the artifact
contract used by the Claude Code skills, but use Codex-native mechanics.

## Shared contract

Read `~/.claude/skills/_shared/pipeline-contract.md` first. It defines the
Changed manifest, Docs section, artifact lifecycle, and universal pipeline
rules. If this repo is installed somewhere else, locate the same file in the
`coding-skills` clone and use that copy.

## Codex translation

- Treat the contract's Opus/Fable model floor as Claude-specific. In Codex, use
  the current session model; use subagents only if documentation scope needs
  independent judgment.
- Treat `/document-plan` as this Codex skill invocation (`$document-plan` or
  selection through `/skills`).
- Earlier stages may have flagged doc drift, but this is the first stage that
  writes docs.

## Preconditions

- The plan has a `## Review` verdict of `Approved` or `Approved (fixed)`.
- The plan has a `## Changed manifest`, `## Result`, and `## Review`.

## Workflow

1. Read the plan manifest, Result, Review, and matching research brief if
   present.
2. Locate the target repo's documentation convention: nearest `AGENTS.md`,
   `CLAUDE.md`, doc map, `docs/` index, module README, schema table, or other
   stated source of truth.
3. If the repo has no documentation convention for the changed area, append
   `## Docs` saying no invariant doc update was warranted and set status Done.
4. Map changed files and symbols, plus research Doc drift items, to docs that
   record affected invariants.
5. Verify each doc claim against live code before editing. Document contracts,
   invariants, edge cases, and why; do not restate implementation bodies.
6. Keep one fact in one canonical home. Link instead of duplicating when a fact
   already exists elsewhere.
7. Update indexes and bidirectional links if this change adds, moves, or renames
   docs.
8. Append `## Docs` with updated docs and reasons, closed drift, duplication
   consolidation, or "no invariant changed; no doc edits". Set `Status: Done`.

## Rules

- Edit docs only. A code mismatch is a review finding, not a doc edit.
- Stay scoped to the Changed manifest and flagged drift.
- Do not commit, stash, push, or use destructive git.
- Respect frozen or immutable docs and vocabularies; flag conflicts instead of
  editing them.
- Use the repo's canonical terminology and stable headings.
