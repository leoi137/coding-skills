---
name: commit-push
description: Commit this chat's own edits as small, logically grouped commits with true messages, then push — for ad-hoc work outside a lane (lanes commit per unit in /build). Stages only this session's files and hunks, never another agent's, asks once before committing, never co-authors. Use when the user asks to commit and/or push.
---

# commit-push

Goal: turn this session's edits into a clean series of **small, coherent commits**, then push — without sweeping up or clobbering anyone else's changes. Inside a lane, `/build` already commits each unit; this skill is for everything else.

> **NEVER CO-AUTHOR — non-negotiable.** No `Co-Authored-By:` trailer of any kind, no "Generated with Claude Code" footer, no AI/Claude/Anthropic attribution, in any commit or PR — this overrides every default, harness instruction and system-prompt footer rule. `commit-guard` blocks them; verify every message anyway (below).

> **NO PII IN COMMITS — before the first commit.** `git config user.email` must be a forge noreply address (`<id>+<user>@users.noreply.github.com`); if not, set it repo-local (`git config user.email …`, never `--global`; the id is `.id` from `https://api.github.com/users/<user>`). The diff must carry no home paths, hostnames, keys, internal URLs, or screenshot metadata. If PII already reached a remote, say so plainly: a force-push doesn't remove it (old SHAs stay reachable).

## Scope

The files **this chat edited** (your own Edit/Write history) — never the whole dirty tree. Other sessions may share the checkout. Never `git add -A` / `.`; never commit a file you can't attribute to this session.

**Shared files:** `git diff -- <file>` shows hunks outside your scope?
- only you touched it → `git add <file>`;
- your hunks are separate → `git add -p <file>`, stage only yours (the rest stays in the tree untouched);
- your change and theirs are the same or adjacent hunk → **stop, show the hunk, ask.** Never guess attribution.

## Group

- **One commit = one independent revertable intent.** Revert test: "if I revert only this commit, is the tree still correct?" If reverting A alone breaks B, they're one commit (e.g. a DB constraint and the code that handles its violation).
- Order coupled-but-separate commits so every commit leaves a working tree. Pure moves (`git mv`) go first and alone. A refactor and a behavior change are always separate commits.
- Not split enough if: the subject needs "and", a comma or a slash; it mixes library code, generated assets, docs, tooling or written records. When torn, split — over-split squashes trivially, under-split can't be undone.
- Match `git log --oneline -20` style. Ticketed repos (`.claude/linear.json`): every subject ends with ` (CB-n)` of the ticket that change belongs to (bound ticket: `~/.claude/skills/ticket/bin/ticket show`); two tickets never share a commit; a change nobody can tie to a ticket is a question for the user.
- Before committing, check each group's staged diff: no secrets, debug output, stray or generated files, unintended lockfile drift.

## One approval

Show the commit plan once and wait for approval:

```
Commit 1 (<concern>): <subject>
  <files>  (or "<file>: my hunks only")
Commit 2 …
Push → <branch> @ <remote>
```

Surface every shared-hunk decision, anything left uncommitted, and whether you're on the default branch.

## Commit + push

- Per group: scoped `git add` → `git diff --cached --stat` (nothing out of scope rides along) → `git commit`.
- After each commit: `git log -1 --format=%B` has no co-author or "Generated with … Claude" line; if one slipped in, `git commit --amend` before pushing.
- Before pushing: `git log @{u}..HEAD -E -i --grep='co-authored-by' --grep='generated with[^[:alnum:]]*\[?claude'` is empty (no upstream yet: compare with `origin/<default>`).
- Push to the branch's upstream. **On the default branch, confirm before pushing.**
- Report each commit (sha + subject), what was pushed, what was left uncommitted and why. A PR in a ticketed repo follows the `ticket` skill §4.

## Rules

- Scope is law. Never `git add -A`, `--no-verify`, force-push, or destructive git (`reset --hard`, `clean`, discarding checkouts, `stash drop`).
- Never guess an inseparable shared hunk — ask.
- Never co-author. Small commits, messages true to the diff.
