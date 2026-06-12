---
name: commit-push
description: Commit and push this session's work as small scoped commits. Use only when the user asks to commit or push, especially after document-plan. Stages only owned changes from the plan manifest or this session; never sweeps unrelated work.
---

# commit-push

Codex adapter for the plan-pipeline commit stage. Preserve the artifact contract
used by the Claude Code skills, but use Codex-native mechanics.

## Shared contract

Read `~/.claude/skills/_shared/pipeline-contract.md` first when committing a
plan flow. It defines artifact lifecycle and universal pipeline rules. If this
repo is installed somewhere else, locate the same file in the `coding-skills`
clone and use that copy.

## Codex translation

- Treat `/commit-push` as this Codex skill invocation (`$commit-push` or
  selection through `/skills`).
- This is the only pipeline stage allowed to commit or push, and only after the
  user explicitly asks for it.

## Scope

Determine the exact owned file/symbol set before staging anything:

- Plan flow: use the plan's `## Changed manifest`. If `## Review` exists, it
  should be `Approved` or `Approved (fixed)` unless the user explicitly confirms
  otherwise.
- No plan: use only files this Codex session actually edited.

Never use `git add -A` or `git add .`.

## Workflow

1. Read recent commit history to match the repo's message style.
2. Group changes into small coherent commits by intent, not by filename alone.
3. For each in-scope file, check whether it also has out-of-scope hunks. Stage
   whole files only when all hunks are owned; otherwise stage only owned hunks.
   If hunks are inseparable, stop and ask the user.
4. Inspect each staged diff for secrets, debug output, unrelated generated
   churn, dependency drift, or out-of-scope changes.
5. Before committing, show one commit plan and get user approval:
   commit subjects, files or partial files, push target, anything left
   uncommitted, and whether the branch is a default branch.
6. For completed plan flows, offer deletion of that plan's TODO and RESEARCH
   artifacts as part of the commit plan. Do not delete artifacts if the user
   declines.
7. Commit each group with scoped staging and accurate messages. Push to the
   current branch's upstream only after approval. If on the default branch, stop
   and confirm before pushing.

## Rules

- Do not commit work you cannot attribute to this plan or this session.
- Do not force-push, use `--no-verify`, run destructive git, or stash/drop work.
- Never add `Co-Authored-By`, `Co-authored-by`, "Generated with", Claude,
  Anthropic, OpenAI, Codex, or other AI attribution trailers/messages.
- Leave out-of-scope work in the worktree untouched.
