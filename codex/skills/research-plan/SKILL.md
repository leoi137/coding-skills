---
name: research-plan
description: Investigate a feature or codebase area before planning or coding. Use when asked to research, understand, map, investigate, trace, or figure out how something works. Produces a research brief in research/ and does not write code or docs.
---

# research-plan

Codex adapter for the plan-pipeline research stage. Preserve the artifact
contract used by the Claude Code skills, but use Codex-native mechanics.

## Shared contract

Read `~/.claude/skills/_shared/pipeline-contract.md` first. It defines the
canonical research path, schema, status rules, and universal pipeline rules.
If this repo is installed somewhere else, locate the same file in the
`coding-skills` clone and use that copy.

## Codex translation

- Treat the contract's Opus/Fable model floor as Claude-specific. In Codex, use
  the current session model; for delegated research, prefer Codex's strongest
  available model/reasoning settings, but do not fail solely because Opus/Fable
  are unavailable.
- Translate Claude `Agent` / `Explore` calls to Codex subagents, preferably the
  read-heavy explorer agent. If subagents are unavailable in the current Codex
  surface, do targeted reads in the main session and keep intermediate output
  compressed.
- Treat `/research-plan` as this Codex skill invocation (`$research-plan` or
  selection through `/skills`).
- The artifact is the handoff. Do not rely on prior conversation context for
  later stages.

## Workflow

1. Restate the research target and scope in one sentence. If the request is
   vague, ask one clarifying question or proceed with an explicit stated
   interpretation.
2. Record the current branch and commit so the brief has a snapshot.
3. If the territory is unknown, run a cheap scout pass to map entry points,
   top-level modules, key symbols, and dead/generated/vendored areas to avoid.
4. Decompose the investigation into the fewest independently answerable angles
   that cover entry points, data/control flow, state and persistence, auth or
   flags, failure boundaries, tests, and integration handoffs.
5. Use parallel Codex subagents when available for non-trivial angles. Prompts
   must be self-contained and require observed/inferred/conflicting/unverified
   distinctions. Ask each agent for compressed findings, not raw dumps.
6. Reconcile contradictions instead of averaging them away. If a load-bearing
   claim conflicts, run one focused verification pass.
7. Write exactly one research brief at
   `research/RESEARCH_<feature>.md`, following the shared contract's research
   schema. Include the Key-file map appendix.

## Rules

- Do not write code, docs, commits, stashes, pushes, or destructive git.
- Mark every claim observed, inferred, conflicting, or unverified.
- Cite symbols and paths, not raw line numbers.
- Keep the brief under roughly 300 lines by cutting repetition before evidence.
- Treat old `plans/` and `research/` artifacts as context, not current truth.
