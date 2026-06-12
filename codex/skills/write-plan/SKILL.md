---
name: write-plan
description: Create a detailed, checklist-driven implementation plan for a feature. Use after research-plan or directly for a small well-understood change. Writes a TODO plan in plans/ with acceptance criteria and an ordered checklist; does not write code.
---

# write-plan

Codex adapter for the plan-pipeline planning stage. Preserve the artifact
contract used by the Claude Code skills, but use Codex-native mechanics.

## Shared contract

Read `~/.claude/skills/_shared/pipeline-contract.md` first. It defines the
canonical TODO path, schema, status ownership, and universal pipeline rules.
If this repo is installed somewhere else, locate the same file in the
`coding-skills` clone and use that copy.

## Codex translation

- Treat the contract's Opus/Fable model floor as Claude-specific. In Codex, use
  the current session model; for delegated planning, prefer Codex's strongest
  available model/reasoning settings, but do not fail solely because Opus/Fable
  are unavailable.
- Translate Claude `Agent` / `Plan` calls to Codex subagents when a planning
  decision needs independent judgment. If subagents are unavailable, plan in the
  main session with targeted reads.
- Treat `/write-plan` as this Codex skill invocation (`$write-plan` or
  selection through `/skills`).
- The TODO artifact is the handoff. Write it so a fresh session can execute it
  without this conversation.

## Workflow

1. Prefer an existing `research/RESEARCH_<feature>.md`. Read it first and use
   its Key-file map. If HEAD moved from the brief snapshot, spot-check that
   load-bearing files and symbols still exist.
2. For a non-trivial target without research, stop and recommend running
   `$research-plan` first. For a small local change, plan directly from the
   request and targeted reads.
3. Define a one-sentence observable goal and 2-6 observable acceptance criteria.
4. Delegate architecture judgment to a Codex subagent when the change crosses
   UI/service/persistence/process/trust boundaries, changes a public contract
   or persisted data, has multiple viable approaches, or the implementation
   path is uncertain.
5. Write exactly one plan at `plans/TODO_<feature>.md`, using the shared
   contract's TODO schema and exact section headings.
6. Phase work on dependency boundaries. Add `(Review checkpoint)` only where a
   risky foundation should be reviewed before later phases build on it.
7. If no safe default exists for a blocking decision, set `Status: Blocked` and
   name the exact decision. Otherwise state assumptions and set `Status: Ready`.

## Rules

- Do not write code, docs, commits, stashes, pushes, or destructive git.
- Name real files and symbols. Mark unconfirmed symbols as `(unverified)`.
- Map tests and validation commands to acceptance criteria.
- Keep parent-session reads targeted: grep and surrounding regions, not broad
  whole-file scouting.
- Report the goal, acceptance criteria, checklist, and any blocking questions to
  the user before execution.
