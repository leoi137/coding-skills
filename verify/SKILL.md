---
name: verify
description: Independently review a lane's whole branch against its plan — reviewers see the plan, the diff, the gate results and CI, never the implementer's reasoning — then fix confirmed defects as commits and record a verdict in .lane/review.md. Runs while CI runs. Top-level session only. Use after /build.
---

# verify

**Read `~/.claude/skills/_shared/pipeline-contract.md` first** — the finding format, gates, CI classes and commit policy live there. Stage 3. Independence comes from what the reviewers see — artifacts and code, never the implementer's narrative — so this stage works the same in a fresh session.

Goal: confirm the branch does what the plan's acceptance criteria say, **fix what's broken**, and don't get sidetracked.

## Preconditions

- **Run from the top-level session.** A fork or subagent can't spawn reviewers and would review single-pass; if you are one, stop and report "ready for /verify from the main session".
- Inside the lane (`lane here`), `.lane/PLAN.md` with every unit ticked and a `## Result`. `lane set <slug> stage=verify`.
- Ticketed repo: bind the plan's ticket if this session hasn't (`ticket show`; bind with no question) — fix commits need it.

## Scope — the branch, nothing else

The review target is `git diff origin/main...HEAD` (the lane's own commits) against `.lane/PLAN.md`. Other branches, main's red, and pre-existing problems outside the diff are not in scope — report at most.

## Deterministic checks first (cheap, no reviewer needed)

1. **Gate is current:** `.lane/gate.json` has `mode: push`, `result: pass`, and `head` equal to `git rev-parse HEAD`. Otherwise run `gate push` (background) and wait.
2. **CI:** `gh pr checks <pr>`; if not finished, start `ci-watch <pr>` in the background and review in parallel — don't wait for it.
3. **Plan vs commits:** every unit ticked has a commit; every acceptance criterion maps to a test that exists in the diff; the `## Log` shows each test went red first.
4. **Gate warnings:** read `.lane/gate-logs/push-added-line-scan.log` warnings (wall clock without fake timers, real-time waits) — they're for the reviewers' checklist.

## Reviewers — on the session's model, in parallel, one message

Each prompt is self-contained and **pastes**: the goal, acceptance criteria and units from PLAN.md, the ticket's description, the diff (or the file list + the reviewer reads the files), the gate summary and CI state. Never "based on the conversation", never the implementer's transcript.

- **S lanes — one reviewer** doing both roles below.
- **M lanes — two reviewers:**
  - **R1 — correctness by re-derivation.** *First derive what "done" must look like from the goal, acceptance criteria and ticket alone — independent of how the plan framed it — then check the code against that.* Catches a wrong plan faithfully implemented. Boundaries, null/error paths, auth, silent failures, state and ordering.
  - **R2 — regressions and test meaning, adversarially.** "This code is wrong — find the input that breaks it." For each changed symbol: call sites and consumers in other packages, serialization, generated code; whether the tests exercise the change or pass vacuously; test standards (frozen time for "today/this week", explicit timeouts, no real sleeps); scope creep, dead code, and whether the docs units match the code.

**Output discipline:** findings only, in the contract's finding format — no narrative, no praise. An empty list is a valid answer.

## Adjudicate and fix

- Reconcile, especially disagreements (R1 says done, R2's call-site sweep finds a broken consumer → that seam is the signal). For each blocker/high, read the few cited lines yourself to confirm.
- **Confirmed defects → fix as commits** in the lane: smallest fix, its test red-then-green, commit `fix: <what> (CB-n)`. After the last fix: one `gate push` (background) and push — CI re-runs on the fixes.
- **Blocker/high fixes get one fresh re-check:** one new reviewer with just the finding and the fix commit. One pass, no loops.
- **Decisions** (product, architecture, scope) → surface to the user; don't auto-decide.
- **Pre-existing or out-of-diff defects** → report only. **Merely improvable code** → leave it (fix what's broken, never what's improvable).

## Verdict → `.lane/review.md`

- **Approved** — every criterion verified, gate green, no blocker/high left.
- **Approved (fixed)** — defects found and fixed as commits; gate green after; blocker/high fixes re-checked.
- **Changes required** — a confirmed blocker/high needs a decision you can't make; list it.
- **Blocked** — the gate or CI couldn't run, or the target is unclear.

`review.md`: `Reviewed: <git rev-parse HEAD after your fixes>`, verdict, each finding (fixed / surfaced / dismissed + why), fix commit shas, CI state at the end. Tell the user the verdict in chat. On Approved / Approved (fixed): `lane set <slug> stage=ship`, next is `/ship`.

## Rules

- Stay in the branch diff. Don't trust ticked boxes or green tests without code evidence.
- No blocking finding without evidence, scenario and impact. Distinguish introduced from pre-existing. Don't grade on a curve, don't invent findings, don't claim exhaustive coverage.
- Never merge, never mark ready, never force-push.
