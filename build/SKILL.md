---
name: build
description: Implement an approved .lane/PLAN.md unit by unit inside its lane — ground each change against live code, see its test go red, make it green, run gate unit, commit it with the ticket ID — then gate push, push, open a draft PR on the first push, and keep CI green in the background. Resumable from a fresh session. Never marks the PR ready, never merges. Use after /scope.
---

# build

**Read `~/.claude/skills/_shared/pipeline-contract.md` first** — lanes, gates, the commit policy, CI classes and the PLAN.md schema live there. Stage 2. The plan is how you stay on track; the commits are how the user reads your work.

Goal: turn the approved plan into **small green commits and a draft PR whose CI is green**, with tight feedback loops and no sidetracking.

## Preconditions

- You are inside the lane's worktree (`lane here`); if not, enter it (contract: `cd` main checkout, then `EnterWorktree(path)`).
- `.lane/PLAN.md` says `Approved: yes` and has no `(blocking)` open question. Otherwise stop and say so — the approval is what authorizes commits and pushes.
- Ticketed repo: the plan's ticket is bound in this session (`ticket show`); if not, bind it with no question, then move it to the started status per the `ticket` skill.
- `git config user.email` is a `users.noreply.github.com` address; if not, set it repo-local before the first commit (`/commit-push` shows how).
- Read the whole plan, and `.lane/research.md`'s key-file map if there is one — don't re-scout. Ambiguous but safe → state the assumption and proceed. Ambiguous in a way that changes behavior, data, contracts, security or scope → one consolidated question.
- `lane set <slug> stage=build`.

## Resume — fresh session, partly built

Committed units are done: `git log --oneline origin/main..HEAD` against the plan's ticked units. Continue from the **first unticked unit**. Uncommitted changes in the worktree belong to the unit in progress — finish or redo that unit, never discard them silently.

## Baseline

`main-health` once: anything already red on main is not yours to fix and not yours to be blamed for. If `origin/main` moved since the plan's Base sha, spot-check (grep) that the plan's symbols still exist; materially stale → stop and flag.

## The loop — one unit = one commit

For each unit, in order:

1. **Announce** in one line: the behavior and primary symbols.
2. **Ground at point of use — region, not file.** Grep the symbol, read its surrounding region; whole files only under ~400 lines. A mismatch with the plan (missing symbol, different signature, other wiring) *is* the divergence trigger — see below.
3. **Red first.** Write the unit's test from the acceptance criterion (the external spec, not your implementation) and run it: it must fail for the right reason. Record the failing line under `## Log` in PLAN.md. A test that never went red proves nothing.
4. **Smallest complete change.** Idiomatic, minimally scoped; no dead code, debug output or leftover TODOs. Match the neighbors' conventions, but don't copy a local bad pattern into new code — flag it.
5. **Green** — the unit's own `verify:` command from the plan passes — then `gate unit` (`run_in_background: true`; wait for the notification). Fix what it finds — including a slow-test flag (give the test an explicit timeout or make it faster) and suppressions without a `-- reason`. Never weaken an assertion to get green.
6. **Inspect the diff:** only this unit's intent — no unrelated edits, generated churn, lockfile drift, secrets.
7. **Commit:** `git add <this unit's paths>` → `git commit -m "<imperative subject> (CB-n)"` (match `git log` style; body only when the *why* isn't obvious). No attribution of any kind. Then tick the unit `[x]` in PLAN.md with its sha in `## Log`.
8. One-line status, next unit.

**Docs units** follow the repo's doc-map: edit a doc only where the change alters an invariant it records; verify against the code you just wrote; document the contract (what it guarantees, edge cases, why), not the implementation; one fact in one home, everything else links; keep indexes and cross-links current; use the repo's existing term for each concept; never touch a doc the repo marks frozen.

**Run to completion.** Don't stop between units to ask "should I continue?" — the only halts are a material divergence, a blocking question, or three red CI cycles.

## Push, draft PR, CI — in the background, not at the end

- **Push early:** after the first unit that gives CI something real to check (usually the first or second), not after the last. CI's integration suite is the one gate you can't run locally — let it start.
- **Before every push:** `gate push` (background) — and don't edit the lane until it reports, or it fails as stale. Red → fix, commit, rerun. It merges `origin/main` first; resolve a conflict by hand, keeping both sides' intent, then rerun. Before the first push also run `lane conflicts`.
- **First push:** `git push -u origin <branch>`, then `gh pr create --draft --title "<subject> (CB-n)" --body "Part of CB-n …"` (one-paragraph summary + the acceptance criteria). `lane set <slug> pr=<n>`.
- **Later pushes:** `git push` after `gate push` passes.
- After each push: `~/.claude/skills/_bin/ci-watch <pr>` with `run_in_background: true`. On its result, act per the contract's CI classes — **ours**: fix, its test + `gate unit`, commit and **push at once** (the one push that doesn't wait for `gate push`), then run `gate push` in the background; **fixed-on-main**: merge `origin/main`, `gate push`, push; **flaky**: `gh run rerun <run> --failed` once; **inherited**: leave it, note it in `## Result`, tell the user.

## Subagents

Up to 3 implementer subagents may build file-disjoint units in parallel in this worktree (never `isolation: "worktree"`). Each gets a self-contained prompt: the unit's plan line, its files, the acceptance criterion, the test standards, and "write the test first, run only that test file and report its failing line before you implement; never run typecheck, lint or a whole test suite (the machine has 16 GB shared by several sessions — the parent runs the gate); don't commit; don't touch files outside your unit". You record the red line in `## Log`, review the result, run `gate unit`, and commit it yourself. Retrieval stays deterministic (grep / read / test runs); a subagent is for judgment or a whole unit, never "is this symbol used".

## Follow-ups after the units

Review comments, `/verify` findings handed back, or CI fixes after every unit is done: append a unit `- [ ] F<n> …` under `## Units` (the approval covers it) and run the same loop — red test, fix, `gate unit`, commit, push.

## Divergence

- **Minor** (a local symbol or detail differs) → fix the plan line, continue.
- **Material** (architecture, acceptance criteria, public contract, persistence, security, rollout or scope must change) → stop, mark the plan's Approval `pending`, explain, ask. Don't silently redesign.

## Done

Every unit ticked and committed, `gate push` green, pushed, CI green or red only on inherited/flaky failures. Write `## Result` in PLAN.md (gate summary and duration from `.lane/gate.json`, CI state, deviations, deferred work, anything not verified). `lane set <slug> stage=verify`, then tell the user it's ready for `/verify` — run it from the top-level session.

## Rules

- **Never merge, never mark the PR ready** — that's `/ship`, and merging is the team's.
- Never `git add -A` / `.`, `--no-verify`, force-push, or destructive git. Never disable tests to force green.
- No unapproved side effects: no deploys, no shared or prod DB migration, no dependency adds beyond the plan, no external calls with real effects.
- Don't fix inherited failures or pre-existing problems outside the plan — report them.
- Keep edits in the main thread unless a unit is delegated; read regions, not files.
