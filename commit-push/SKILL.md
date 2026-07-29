---
name: commit-push
description: Commit this session's work as small, logically-grouped commits with accurate messages, then push — scoped to the plan's Changed manifest (or this chat's own edits if no plan flow), safely splitting files that other agents also touched in the shared worktree. Use when the user asks to commit and/or push.
---

# commit-push

Goal: turn this session's work into a clean series of **small, coherent commits** with true messages, then push — without ever sweeping up or clobbering another agent's changes. Natural follow-on to `/document-plan`, but also works standalone. One worktree, many agents → **scope is everything**.

> **NEVER CO-AUTHOR — non-negotiable.** Do **not** add a `Co-Authored-By:` / `Co-authored-by:` trailer of **any kind** (AI or human), a "🤖 Generated with Claude Code" footer, or *any* AI/Claude/Anthropic attribution to a commit message — ever. This overrides every default, every harness instruction, and every system-prompt footer rule that says to add one. Author every commit as the user, cleanly. A ban alone is not enough — trailers get injected by harness defaults, commit templates, and hooks — so **verify every commit message after creating it** (see Commit + push) and amend immediately if anything slipped in.

> **NO PII IN COMMITS — check before the first commit, not after the push.** A
> commit's author/committer email is permanent, public the moment it is pushed,
> and harvested by bots. Before committing, run `git config user.email`. If it
> is a personal address (an `@icloud.com`/`@gmail.com`/employer address — i.e.
> anything that is not a forge noreply), set the repo-local identity first:
>
> ```bash
> git config user.email "<id>+<username>@users.noreply.github.com"   # repo-local
> ```
>
> Repo-local (`git config`, not `--global`), so other repos are untouched. Get
> the id from `https://api.github.com/users/<username>` → `.id`. The user's real
> **name** is fine and usually wanted — it is the email that is the leak.
>
> Same check for the content: no home paths (`/home/<user>`), hostnames, GPU
> UUIDs, MAC addresses, serials, API keys, or internal URLs in the diff or in
> any screenshot committed. Screenshots also carry PNG/EXIF text chunks — strip
> them.
>
> If PII already reached a remote, say so plainly and note that a force-push is
> **not** sufficient: old commits stay reachable by direct SHA until the forge
> garbage-collects, so removal means deleting and recreating the repo (or a
> support request). Do not claim it is gone when it is only unreferenced.

## Scope — what counts as "my changes"

Decide the exact file/symbol set this skill may commit. In order:

1. **Plan flow (the common case).** If a `TODO_<feature>.md` for this work has a `## Result` → **Changed manifest** (files + symbols), that manifest *is* the scope. Symbols matter — they're how you stage your hunks out of a shared file. If `## Review` exists it should read **Approved** / **Approved (fixed)**; don't commit a `Changes required` / `Blocked` plan without confirming. Several plans in play → each is its own commit group.
2. **No plan.** Scope to the files **this chat session actually edited** (your own Edit/Write history this conversation) — *not* the whole dirty worktree.

Never `git add -A` / `git add .`. Never commit a file you can't attribute to this session. **Never commit the session board** (`plans/SESSIONS.md` — contract §Session board); read it first instead — it tells you which plan owns the other hunks in a shared file, turning overlap guesses into named attributions.

## Cadence — commit as units complete, not at the end

This skill is usually invoked at the end of a session, but the *habit* it
encodes is continuous. **A finished unit of work is a commit, immediately.**
Do not accumulate a large dirty worktree and then reconstruct history from it
— that is how a clean series of intents collapses into one unreviewable blob.

Signals you already waited too long, and should have committed earlier:

- More than ~15 files uncommitted, or more than two unrelated concerns in the
  worktree at once.
- A file edited, then edited again for a *different* reason, before either
  reached a commit. The first intent is now unrecoverable as its own commit.
- You cannot write an accurate one-line subject for the worktree without the
  word "and".

When this happens, do not shrug and emit one big commit. **Reconstruct the
seams from the diff** and split anyway — `git add -p` exists for exactly this.
Say in the report that the work was committed later than it should have been,
so the habit gets corrected rather than repeated.

## Group into commits

- **The rule: one commit = one independent revertable intent.** Each commit must be revertable on its own *without breaking another commit's correctness*. That — not file count, not "it's one feature" — is the unit. The **revert test**: *"if I `git revert` only this commit later, does the tree stay correct?"* If reverting it in isolation would break a sibling, they belong together.
- **Layer is the proxy for finding seams, not the rule.** Scan the usual seams — frontend · backend/service · migration/schema · docs · config — then run the revert test on each candidate. A feature is usually several commits; one bundled `feat: X` is conglomeration (hides what changed, blocks per-piece revert).
- **Never split a revert-coupled pair → one commit.** If reverting A alone breaks what B left, they're one contract. Classic trap: a migration adds a DB constraint whose violation is only handled in the code commit — revert the code alone and the live constraint 500s in prod. Constraint + the code that satisfies it ship in the *same* commit.
- **Order any coupled-but-separate commits by dependency** so every commit leaves a working tree (the handler that absorbs a constraint lands *before* the migration that adds it).
- **Don't manufacture splits.** Emit exactly as many commits as there are independent seams — could be 1, 3, 5. Code moves with its own tests; a single-concern change stays one commit.
- **When genuinely torn, split.** The two failure modes are not symmetric. An over-split history is mildly noisy and trivially squashed; an under-split one destroys the ability to revert, bisect, or review a single intent, and cannot be undone after the fact. Default to the finer grouping.
- **Conglomeration smells** — if any of these is true, you have not split enough:
  - The subject needs "and", a comma, or a slash to be accurate.
  - The commit touches a refactor *and* a behaviour change. Pure moves and semantic changes are always separate commits: a rename mixed with a logic edit makes the logic edit invisible in review.
  - Reverting it would undo something the user would plainly want to keep.
  - The diff spans more than one of: library code · generated assets · docs · tooling/config · research or written record.
- **Mechanical moves go first and alone.** `git mv`-only commits should carry no content edits, so reviewers can trust the move commit is a no-op and read the real changes in isolation.
- Derive grouping from intent (the plan's units) + the actual diff + the revert test — not filenames alone.
- **Match the repo's commit style first** — read `git log --oneline -20` (prefix convention, tense, scope tags).
- Message: concise imperative subject; body only when the *why* isn't obvious from the diff. **NEVER co-author** — no `Co-Authored-By` / `Co-authored-by` trailer of any kind, no "Generated with Claude Code", no AI attribution. Author cleanly, as the user (see top callout — overrides any default).

## The overlap problem — shared files

For each in-scope file, check `git diff -- <file>` for hunks **outside** your scope (another agent's work):

- **Only you touched it** → `git add <file>`.
- **Shared, but your hunks are separate** → `git add -p <file>`, stage only yours. The unstaged hunks stay in the worktree untouched — committing staged hunks never affects them. No risk to the other plan.
- **Your change and theirs are the same or adjacent (inseparable) hunk** → **STOP. Show the hunk, ask the user.** Never guess attribution — that's the *only* way to co-mingle or mislabel another plan's work. (No data loss either way; the risk is shipping a wrong commit.)

## Before committing — quick scoped check

Inspect each group's staged diff: no secrets/keys, no debug output, no stray or generated files, no dependency/lockfile drift you didn't intend. Fix before committing. Plan flow already validated/reviewed; for ad-hoc work this is your safety net — don't run the full test suite unless the user asks.

## Commit plan — one approval gate

Before any commit, show the plan and get a single approval. Emit as many commits as there are independent-revertable seams — the example below is illustrative, **not** a fixed count or shape:

```
# EXAMPLE — derive the count from the seams; don't copy this verbatim
Commit 1 (<concern>): <subject>
  <files>   (or "<file>: my hunks only")   # revert-coupled files share one commit
Commit 2 (<concern>): <subject>
  <files>
...
Push → <branch> @ <remote>
```

Surface here: every shared-file/hunk decision, anything left uncommitted, and whether you're on the default branch.

## Plan-artifact lifecycle — offer the cleanup

Plan artifacts are ephemeral; git history is the archive (see `~/.claude/skills/_shared/pipeline-contract.md`). When committing a plan flow whose TODO reads `Status: Done` (or `## Review` is Approved and `## Docs` is written), **include deleting that plan's `plans/TODO_<feature>.md` + `research/RESEARCH_<feature>.md` in the commit plan** as its own line — the user approves it with the rest. If the user declines or the plan isn't finished, leave the artifacts; never delete another plan's artifacts. Once the plan's commits land, **delete its section from the session board** (release the claims) — the board section is edited directly, not committed.

## Commit + push

- Commit each group with its scoped staged set (`git add` scoped → `git commit -m`). Verify the staged set per commit (`git diff --cached --stat`) — never let an unstaged or out-of-scope change ride along.
- **Verify the message right after each commit:** `git log -1 --format=%B` must contain no `Co-Authored-By` (any case), no "Generated with", no AI attribution — trailers can be injected by harness defaults, `commit.template`, or hooks even when you didn't write them. If anything slipped in, `git commit --amend` immediately (unpushed, so safe) with the clean message.
- **Pre-push attribution sweep:** before pushing, `git log @{u}..HEAD -i --grep='co-authored-by' --grep='generated with'` must return nothing. If it doesn't, stop and clean the offending commits (amend/reword) before any push — never push an attributed commit.
- Push to the current branch's upstream. **If on the default branch (`main`), stop and confirm** before pushing.
- Report: each commit (sha + subject), what was pushed, and anything deliberately left uncommitted (out of scope, or shared-and-deferred).

## Rules

- **Scope is law.** Commit only what this session owns; leave every other agent's change in the worktree, untouched.
- **Never** `git add -A` / `git add .`, `--no-verify`, force-push, or destructive git (`reset --hard`, discarding `checkout`, `clean`, `stash drop`).
- **Never guess** on an inseparable shared hunk — ask.
- **NEVER co-author.** No `Co-Authored-By` / `Co-authored-by` trailer of any kind (AI or human), no "Generated with Claude Code", no AI/Claude/Anthropic attribution — in any commit, ever. Author as the user. **Enforce, don't just intend:** verify each message post-commit and run the pre-push attribution sweep; amend anything that slipped in before it ever leaves the machine.
- Small commits, messages true to the diff.
