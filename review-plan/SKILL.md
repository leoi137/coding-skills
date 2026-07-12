---
name: review-plan
description: Independently review just the changes a plan made — scoped to that plan's manifest — against its acceptance criteria, for correctness, regressions, and scope creep. Fixes confirmed issues in place; never commits. Use after /execute-plan.
---

# review-plan

**Read `~/.claude/skills/_shared/pipeline-contract.md` first** — it defines the manifest format, finding format, model floor, and universal rules. Stage 4 of the pipeline. Independence comes from reviewers seeing the *artifacts and code*, never the implementer's reasoning — this stage must work identically in a fresh session.

Goal: go over **only the changes this plan made**, confirm they actually satisfy the goal, **fix what's broken**, and don't get sidetracked.

> **Model floor:** every reviewer runs Opus or Fable — never below Opus-class — passed explicitly (full policy in the contract). All reviewers run at the same frontier tier; since two copies of one model share blind spots, independence is bought via **adversarial framing + spec re-derivation** (below), not model diversity.

## Scope — the plan's manifest, NOT the whole diff

Multiple sessions share this worktree, so `git status` shows other plans' files too. Reviewing all of it *is* the sidetrack. Set this plan's session-board entry to `Stage: review` (contract §Session board) — and use the board's other sections to *name* which plan owns foreign hunks in shared files.

- Read the plan's **`## Changed manifest`** (files + symbols `/execute-plan` checkpointed). That set — intersected with the live working-tree diff — is the review target. Nothing else.- **Shared file** (this plan + another session both edited it): scope to the **hunks touching this plan's symbols** only. Leave the other hunks alone.
- **Can't cleanly separate** this plan's changes from another's (interleaved edits in the same function)? → verdict `Blocked: target ambiguous`. Don't review or fix — a fix could clobber the other session's work.

## Validation — run once, read-only

The orchestrator runs the plan's validation commands once and records exact command + result + counts. Compare to execute's claimed Result: **green-in-execute / red-in-review is itself a finding** (the tree or env moved). Passing tests are evidence, not proof. Don't run formatters / generators / migrations that mutate reviewed source.

## Reviewers — 3 in parallel, one message, each frontier-tier

Each prompt is self-contained and **pastes** the goal, acceptance criteria, the Changed manifest, and the validation results — never "based on the conversation," never the implementer's narrative.

- **A — Correctness vs the real goal (spec re-derivation).** *First derive what "done" should look like from the goal + research brief alone — independent of how the plan framed it — then check the code against that.* Catches a wrong plan faithfully implemented. Cover boundaries, null/error paths, auth, silent failures, state/ordering. Audit checklist items against code, not ticked boxes.
- **B — Regressions & contracts.** For each changed symbol, find call sites + consumers (other layers/packages, serialization, generated code) and judge compatibility. Assess whether existing tests *meaningfully* exercise the change or pass vacuously.
- **C — Quality, simplicity & scope.** Dead code, premature abstraction, unrelated refactoring, scope creep beyond the plan, comments that restate code, dependency churn. Frame this reviewer **adversarially**: "this code is wrong — find the input that breaks it."

**Output discipline:** findings only, each in the contract's finding format (severity · confidence · location · scenario · impact · fix direction, ≤150 words) — no narrative, no praise, no restating what's fine. Subagents drop their own low-confidence noise. An empty finding list is a valid output.

## Adjudicate, fix, report

The parent reconciles — especially **disagreements** between reviewers (A says done, B's call-site sweep says a consumer breaks → that seam is the signal). For a blocker/high, pull the specific few lines the finding cites to confirm it (targeted point-of-use read — never the whole diff).

Then **fix what you find** (the user wants issues fixed, not just listed):
- **Confirmed code-level defects** → fix in place (no commits), then re-run that finding's test/validation to prove the fix.
- **Blocker/high fixes get one independent re-check:** spawn ONE fresh reviewer subagent with just the finding + the fixed hunks — the mind that wrote the fix doesn't get to be the only one approving it. One pass, no loops; med/low fixes need only their re-run validation.
- **Anything needing a product / architecture / scope decision** → surface it, don't auto-decide. Auto-deciding those *is* sidetracking.
- **Pre-existing unrelated defects** (outside the manifest) → report at most; never fix. Wandering into them is the sidetrack.

**Verdict** (not "ship" — review ≠ deploy). Failing required tests hard-gate to *not approved*:
- **Approved** — criteria verified, validation green, no blocker/high left.
- **Approved (fixed)** — issues found and fixed in place; validation green after the fix (and blocker/high fixes re-checked).
- **Changes required** — a confirmed blocker/high needs a decision you can't make here; list it.
- **Blocked: insufficient evidence** — ambiguous target or validation couldn't run.

Report in chat + append a short `## Review` section to the TODO (verdict, what was fixed, anything surfaced; in checkpoint mode, note which phases the verdict covers). No separate artifact. On **Approved** / **Approved (fixed)**: full review → next stage is `/document-plan`; checkpoint review → `/execute-plan` resumes.

## Rules

- **Stay in scope:** the manifest ∩ diff, nothing else. The boundary is the anti-sidetrack mechanism.
- **No commits, stashes, or pushes** — fixes land in the working tree for the user to read.
- **Don't trust ticked boxes or passing tests** without code evidence.
- **No blocking finding without evidence + scenario + impact.** ("No false positives" is unachievable; this is the real bar.) Distinguish introduced from pre-existing.
- **Don't grade on a curve** — if it's solid, say so plainly and approve. Don't invent findings to look useful.
- **Don't claim exhaustive coverage**; label uncertainty.
