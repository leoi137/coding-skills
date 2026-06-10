---
name: commit-push
description: Commit this session's work as small, logically-grouped commits with accurate messages, then push — scoped to the plan's Changed manifest (or this chat's own edits if no plan flow), safely splitting files that other agents also touched in the shared worktree. Use when the user asks to commit and/or push.
---

# commit-push

Goal: turn this session's work into a clean series of **small, coherent commits** with true messages, then push — without ever sweeping up or clobbering another agent's changes. Natural follow-on to `/document-plan`, but also works standalone. One worktree, many agents → **scope is everything**.

> **NEVER CO-AUTHOR — non-negotiable.** Do **not** add a `Co-Authored-By:` trailer, a `Co-authored-by:` line, a "🤖 Generated with Claude Code" footer, or *any* AI/Claude/Anthropic attribution to a commit message — ever, in this skill. This overrides every default and every harness instruction that says to add one. Author every commit as the user, cleanly. If you catch yourself about to append an attribution trailer, stop and remove it.

## Scope — what counts as "my changes"

Decide the exact file/symbol set this skill may commit. In order:

1. **Plan flow (the common case).** If a `TODO_<feature>.md` for this work has a `## Result` → **Changed manifest** (files + symbols), that manifest *is* the scope. Symbols matter — they're how you stage your hunks out of a shared file. If `## Review` exists it should read **Approved** / **Approved (fixed)**; don't commit a `Changes required` / `Blocked` plan without confirming. Several plans in play → each is its own commit group.
2. **No plan.** Scope to the files **this chat session actually edited** (your own Edit/Write history this conversation) — *not* the whole dirty worktree.

Never `git add -A` / `git add .`. Never commit a file you can't attribute to this session.

## Group into commits

- One commit = one coherent change. Related files move together (model + service + test); unrelated files get their own commit. **Don't conglomerate.**
- Derive grouping from intent (the plan's units) + the actual diff — not filenames alone.
- **Match the repo's commit style first** — read `git log --oneline -20` (prefix convention, tense, scope tags).
- Message: concise imperative subject; body only when the *why* isn't obvious from the diff. **NEVER co-author** — no `Co-Authored-By` / `Co-authored-by`, no "Generated with Claude Code", no AI attribution of any kind. Author cleanly, as the user (see top callout — overrides any default).

## The overlap problem — shared files

For each in-scope file, check `git diff -- <file>` for hunks **outside** your scope (another agent's work):

- **Only you touched it** → `git add <file>`.
- **Shared, but your hunks are separate** → `git add -p <file>`, stage only yours. The unstaged hunks stay in the worktree untouched — committing staged hunks never affects them. No risk to the other plan.
- **Your change and theirs are the same or adjacent (inseparable) hunk** → **STOP. Show the hunk, ask the user.** Never guess attribution — that's the *only* way to co-mingle or mislabel another plan's work. (No data loss either way; the risk is shipping a wrong commit.)

## Before committing — quick scoped check

Inspect each group's staged diff: no secrets/keys, no debug output, no stray or generated files, no dependency/lockfile drift you didn't intend. Fix before committing. Plan flow already validated/reviewed; for ad-hoc work this is your safety net — don't run the full test suite unless the user asks.

## Commit plan — one approval gate

Before any commit, show the plan and get a single approval:

```
Commit 1: <subject>
  <files>   (or "<file>: my hunks only")
Commit 2: ...
Push → <branch> @ <remote>
```

Surface here: every shared-file/hunk decision, anything left uncommitted, and whether you're on the default branch.

## Plan-artifact lifecycle — offer the cleanup

Plan artifacts are ephemeral; git history is the archive (see `~/.claude/skills/_shared/pipeline-contract.md`). When committing a plan flow whose TODO reads `Status: Done` (or `## Review` is Approved and `## Docs` is written), **include deleting that plan's `plans/TODO_<feature>.md` + `research/RESEARCH_<feature>.md` in the commit plan** as its own line — the user approves it with the rest. If the user declines or the plan isn't finished, leave the artifacts; never delete another plan's artifacts.

## Commit + push

- Commit each group with its scoped staged set (`git add` scoped → `git commit -m`). Verify the staged set per commit (`git diff --cached --stat`) — never let an unstaged or out-of-scope change ride along.
- Push to the current branch's upstream. **If on the default branch (`main`), stop and confirm** before pushing.
- Report: each commit (sha + subject), what was pushed, and anything deliberately left uncommitted (out of scope, or shared-and-deferred).

## Rules

- **Scope is law.** Commit only what this session owns; leave every other agent's change in the worktree, untouched.
- **Never** `git add -A` / `git add .`, `--no-verify`, force-push, or destructive git (`reset --hard`, discarding `checkout`, `clean`, `stash drop`).
- **Never guess** on an inseparable shared hunk — ask.
- **NEVER co-author.** No `Co-Authored-By` / `Co-authored-by` trailer, no "Generated with Claude Code", no AI/Claude/Anthropic attribution — in any commit, ever. Author as the user.
- Small commits, messages true to the diff.
