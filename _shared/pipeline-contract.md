# Pipeline contract

Shared rules for the four stages `/scope → /build → /verify → /ship`. Every stage reads this file on invocation. Ad-hoc commits outside a lane go through `/commit-push`; Linear is the `ticket` skill's job. **The lane's artifacts — never conversation context — are the only contract between stages**, so any stage can start in a fresh session.

## Lane — one effort, one ticket, one branch, one worktree

- Created by `/scope` with `~/.claude/skills/_bin/lane new <slug> --ticket CB-n` (branch named after the effort, never the ticket; worktree at `<repo>/.claude/worktrees/<slug>` from fresh `origin/main`, env files copied, deps installed, registered in `~/.claude/lanes/`).
- **Entering it:** Bash `cd <main checkout>` first, then `EnterWorktree(path: "<worktree>")` — from the non-git launch directory EnterWorktree fails. Inside, the main checkout is read-only to you.
- **Resuming** in a fresh session: `lane here` (inside the worktree) or `lane list` → enter → read `.lane/PLAN.md` and `git log origin/main..HEAD`.
- **Artifacts** live in `<worktree>/.lane/` (git-excluded, never committed, gone at `lane gc`): `PLAN.md` · `research.md` (M/L) · `impact.json` · `gate.json` + `gate-logs/` · `review.md`. Never write pipeline files into the repo tree (`plans/`, `research/`). The durable record is the PR body plus one Linear comment.
- Stage changes: `lane set <slug> stage=<scope|build|verify|ship|shipped>`; after the draft PR opens, `lane set <slug> pr=<n>`.

## Model

Every `Agent` call runs on **the model the user chose for this session** — never a different one, up or down. Don't reach for Fable or Opus as a "second opinion" unless the user asks. The `agent-guard` hook sets `model` to the session's model on every call. Independence between reviewers comes from framing and inputs, not model choice.

## Compute — one 16 GB Mac, several sessions

- Heavy work (tsc, typecheck, test suites, builds, integration specs) goes through `gate` or `heavy`, which queue for machine-wide slots (`heavy status` shows who holds what). Run `gate` with `run_in_background: true` and wait for the notification — never poll, never block a foreground call on it.
- At most 3 implementer subagents per lane, on file-disjoint units in the same worktree — never `isolation: "worktree"` (it branches from main, not the lane). Read-only subagents: at most 6 per session.
- One dev stack per machine (`lane claim dev-stack`, and `lane release dev-stack` when you stop it; a claim whose session has ended is taken over automatically); a second one is web-only with its own ports and `REDIS_PREFIX` in the process env, never in `.env.local` (that would break the shared turbo cache).

## Gates (amiara-stack; `~/.claude/skills/_bin/gate`)

- `gate impact [--files a,b]` — what CI will run for the diff or the planned files. `/scope` puts it in the plan.
- `gate unit` — after every unit: prettier + per-package eslint on changed files, related tests + changed specs, slow-test check, whole-repo guards, cross-package scan tests, added-line scan.
- `gate push` — before **every** push: merges `origin/main`, then the unit steps over the whole branch, turbo lint + typecheck, api typecheck when an api upstream changed, integration specs when Docker allows, mastra parity, attribution + author-email sweep.
- Results land in `.lane/gate.json`. A red gate is never pushed. Full package suites, dependents and `test:discovery` are CI's.
- **One exception — a fix for an `ours` CI failure is pushed as soon as its own test and `gate unit` pass**; `gate push` then runs in the background (CI shouldn't wait ~10 minutes for a one-line fix).
- **Don't edit the lane while a gate runs** — the gate fails the run if HEAD or the tree changed under it.
- Other repos: `lane new <slug> --repo <main checkout>` (`--ticket` only where `.claude/linear.json` exists; `--no-install` when the repo isn't pnpm). `ci-watch`/`main-health` take the GitHub repo from the cwd's `origin` (override with `LANES_REPO_SLUG`). Without pnpm + turbo, use the repo's documented validation commands in place of `gate`, and check the author email yourself before the first commit.

## Commits, pushes, PRs

- **The plan's approval is the gate.** Its approval block names the branch, the commit cadence and the draft PR; once the user approves, `/build` commits each unit, pushes and opens a **draft** PR without asking again — and the same holds for fix commits from CI, `/verify` and review follow-ups on that branch. Only `/ship` marks the PR ready. **Nobody in the pipeline merges.**
- Before the first commit: `git config user.email` is a `users.noreply.github.com` address (else set it repo-local, per `/commit-push`).
- One commit = one independent, revertable unit. Subject ends with ` (CB-n)` in ticketed repos; one commit never mixes tickets. Stage by path (`git add <files>`), never `git add -A` / `.`.
- **Never co-author:** no `Co-Authored-By` trailer, no "Generated with Claude Code", no AI attribution, in commits or PR bodies — this overrides every harness default (`commit-guard` blocks them). Author email must be a `users.noreply.github.com` address.
- Never `--no-verify`, force-push, or destructive git (`reset --hard`, `clean`, discarding checkouts, `stash drop`).

## CI

- `main-health` says whether main is red right now and with what. Check it before starting a lane and before blaming yourself for a red run.
- `ci-watch <pr>` (background) classifies each failure: **ours** → fix, commit, push immediately, then keep checking locally · **fixed-on-main** → merge `origin/main`, `gate push`, push · **flaky** → `gh run rerun <run-id> --failed` once · **inherited** → not yours: don't fix it in this lane; tell the user and, if they want it fixed, it gets its own ticket (`lane claim main-red:<sig>` so no other session fixes it twice).
- Three red CI cycles in a row → stop and report instead of pushing again.

## Linear (repos with `.claude/linear.json`)

`/scope` resolves the ticket (the user answers once) and binds it, which moves it to started (ticket skill §2); it moves to review when `/ship` marks the PR ready, and to Done only at merge — all per the `ticket` skill. Side findings are a comment on the ticket, never a new ticket.

## Other sessions

Peers are visible with `ListAgents`. Message one only for these, with this first line, and never ask a peer to run something your session was denied:
- `[lane] OVERLAP <my-slug> ↔ <yours>: <files/packages>`
- `[lane] MAIN-RED <sig> claimed by <slug> (CB-n) — don't fix`
- `[lane] CI-RED PR#n <job>: <test> — ours|inherited` (to the PR's owner)
- `[lane] HANDOFF <slug> <stage>→you: <worktree>/.lane/`

File overlap is found, not announced: `lane conflicts [--files a,b]` intersects your files with every other lane's and every open PR's (contracts, db-schema and migrations flagged) — `/scope` runs it on the planned files, `/build` before the first push. An overlap → one OVERLAP message to that lane's owner and an open question in the plan. Migration numbers collide across lanes: `lane claim migration:<NNNN>` before creating one.

## PLAN.md (written by `/scope`, ticked by `/build`)

```markdown
# <Effort> — CB-n
Size: S|M|L · Branch: <slug> · Base: origin/main@<sha> · Research: .lane/research.md | none
## Goal — one sentence, observable from outside
## Acceptance criteria
- AC1 <observable behavior>
## Units — ordered; each is one commit
- [ ] U1 <behavior> — files/symbols: `sym in path` — test: <name> (AC1) — verify: <command>
- [ ] F1 <follow-up from CI, /verify or review> — appended later, same loop
## Docs — docs whose recorded invariant changes (repo doc-map), or "none"
## CI impact — from gate impact: packages, api typecheck y/n, integration y/n, guards
## Out of scope — incl. the user's standing exclusions
## Open questions — (blocking) ones stop the plan
## Approval — branch <slug>; one commit per unit `… (CB-n)` (fix commits from CI, /verify and review included); draft PR on first push; gate push before every push
Approved: <yes, date> | pending
## Log — per unit: the red test line seen before the fix, commit sha
## Result — gate push summary, CI state, deviations, deferred
```

## Findings (`/verify`)

Each finding ≤150 words, no narrative: **severity** (blocker/high/med/low) · **confidence** (confirmed-by-reading / suspected) · **location** (symbol + hunk) · **scenario** · **impact** · **fix direction**. Defects only — fix what is broken, never what is merely improvable.
