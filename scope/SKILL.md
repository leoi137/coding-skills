---
name: scope
description: Start a piece of work — or just investigate one. Resolves the Linear ticket, creates the lane (its own worktree and branch from fresh origin/main), sizes the work S/M/L, researches as much as the size needs, and writes an approvable .lane/PLAN.md with acceptance criteria, one-commit units, docs impact and what CI will run. Research-only mode answers "how does X work" with a cited brief and no lane. Writes no code. Use first, before /build.
---

# scope

**Read `~/.claude/skills/_shared/pipeline-contract.md` first** — lanes, gates, the commit policy and the PLAN.md schema live there. Stage 1. The plan you write is the only thing `/build` gets, so write it for a fresh session with zero other context.

Goal: turn an ask into an **approved, file-level plan** in its own lane, sized so it lands green on the first push — or, in research-only mode, into a decision-useful brief.

## 0. Which mode

- **Research only** — the user wants to understand, map or investigate ("how does X work", "figure out why…") with no build intent yet. Skip the lane and ticket: run step 5's research from the main checkout, answer in chat with the brief (structure below), and offer `/scope` for real when they want to build. Nothing is written to the repo.
- **Build** — everything below.

## 1. Restate, check main

Restate the target in one sentence with explicit scope. Vague → one clarifying question, or proceed on a stated interpretation; never guess silently. Run `~/.claude/skills/_bin/main-health`: if main is red, say so now (with the failing signatures) so nobody later mistakes inherited red for this lane's.

## 2. Ticket (repos with `.claude/linear.json`; skip elsewhere)

Resolve the ticket through the `ticket` skill — the user names one, or you find candidates and ask once (continue / new / none). Bind it (`ticket bind … --repo <main checkout>`). One ticket per lane; if the ask spans two deliverables, that's an L — see step 3.

## 3. Size — the cheapest place to stop a red PR

Small PRs went green first time 5 of 5; large ones 7 of 17. Size from the planned change, not the ask's wording — a quick grep-level look is enough here; research (step 5) may revise it:

- **S** — ≤3 files, 1 package, no `packages/contracts`, no `packages/db-schema`, no migration. Plan ≈ 20 lines; no research subagents.
- **M** — anything between. Full plan; parallel research when the territory is unknown.
- **L** — more than one deliverable, or more than ~600 changed lines, or more than 3 packages. **Don't plan it as one lane.** Propose the split (each part an S or M with its own ticket, in dependency order) and let the user choose. Cutting here costs a message; cutting after a red PR costs a day.

## 4. Lane

`~/.claude/skills/_bin/lane new <effort-slug> --ticket CB-n --size S|M` (slug after the effort: `cross-chat-search`, never `cb-600`; no `--ticket` in a repo without `.claude/linear.json`). Run it with the Bash `timeout` at 600000 — the install can take minutes. It fetches `origin/main`, creates the worktree and branch, copies the env files, installs, and registers the lane. Then enter it exactly as the contract says: Bash `cd <main checkout>`, then `EnterWorktree(path: …)`. Everything from here on happens inside the lane.

## 5. Research (M; S only if something is unclear)

Heavy reading happens in subagents; only compressed findings come back. Decision-useful, not complete: entry points, data/control flow, state & persistence, auth/flags/error boundaries, the tests that cover it, open risks. Stop there.

- **Scout first** if the territory is unknown: one subagent maps the tree, key modules and symbols, and dead/generated/vendored zones to skip. Decompose against its map.
- **Angles:** the fewest that cover the list above (typical: entry/UI · backend/control flow · data & persistence · auth/flags/errors · tests), plus **one cross-cutting angle** for anything non-trivial — seam bugs live in the handoffs.
- **`Explore` subagents in parallel** (one message, several calls). Each prompt is self-contained: the feature and why, the angle and its exclusions, known start paths, the snapshot sha; "read the repo's distilled docs (`docs/`, AGENTS.md doc-map) first as a map, then verify against code"; "**distinguish what you observed in code from what you inferred.**" Output under 400 words: summary · key evidence (`symbol in path` — why it matters) · flow (numbered) · observed vs inferred · doc drift · gotchas · open questions.
- **Reconcile:** surface contradictions between angles instead of averaging them — that's where the bugs are. An empty or failed angle is reported, not dropped. At most one follow-up wave for a disputed load-bearing claim.
- Research can change the size: an M that turns out to touch 4 packages or a migration plus contracts is an L — stop and propose the split before planning. If the user takes the split, `lane drop <slug>` (leave the worktree first: `ExitWorktree` keep) and scope each part as its own lane.
- Write `.lane/research.md` (≤ ~200 lines): architecture facts · key files & symbols · flow · boundaries · existing tests · risks & unknowns · doc drift · a **key-file map** (`path — one-line role`) so `/build` never re-scouts. Cite symbols, not line numbers; mark each claim observed / inferred / unverified.

## 6. Plan

- **Delegate architecture to a `Plan` subagent** when the change crosses a boundary (UI / service / persistence / process / trust), changes persisted data or a public contract, or has more than one viable approach. Brief it self-contained (paste, don't link) and require: "**ground every symbol you name by opening the file it lives in; mark anything you can't confirm `(unverified)`**." Small, local changes: plan in the main thread with grep + targeted region reads — never whole-file reads to "make sure."
- **Units:** each unit is one commit — the smallest change that reaches a valid, testable state (model + service + test move together). Dependency order. Name real symbols (`updateGoalProgress in src/services/strategyService.ts`), never "update the service layer."
- **Tests map to acceptance criteria.** Every behavior change gets a named test, written to go red first. Follow the repo's test standards: no wall clock without fake timers, explicit timeouts on slow tests, no real sleeps, no `.only`/`.skip`.
- **Docs:** map the planned change onto the repo's doc-map (AGENTS.md / CLAUDE.md "when you change X update Y", `docs/` reference tree). A doc is in scope only if an invariant it records changes; the update becomes a unit like any other. Add any doc drift research found in the area.
- **CI impact:** run `gate impact --files <planned files, comma-separated>` inside the lane and copy its summary (packages, api typecheck, integration, guards) into the plan. If it shows `packages/contracts` or db-schema in an S, it isn't an S.
- **No premature abstraction or shims** — unless a named consumer, migration or rollout needs it; then write down when it goes away.
- Migrations: `lane claim migration:<NNNN>` before planning a new one.
- **Overlap:** `lane conflicts --files <planned files>`. Another lane or open PR touching the same files → one `[lane] OVERLAP …` message to its owner (contract format) and an open question in the plan (blocking when it's the same symbols, contracts, db-schema or a migration).

## 7. Write `.lane/PLAN.md` and ask for approval

Use the contract's PLAN.md schema exactly — `/build` finds sections by heading. Open questions with a safe, conventional default become stated assumptions; a question without one is `(blocking)` and the plan stays pending.

Show the user: goal, acceptance criteria, units, CI impact, out of scope, the approval block. **Their approval authorizes `/build` to commit each unit, push, and open a draft PR on the lane's branch without asking again** — say that in one line so the approval is informed. Record `Approved: yes, <date>` only on an explicit yes. Then `lane set <slug> stage=build`.

## Research brief (research-only mode, in chat)

Target & scope · snapshot (branch@sha) · 5–8 load-bearing architecture facts · key files & symbols · end-to-end flow (numbered) · state, auth & failure boundaries · existing tests · risks, contradictions, unknowns · doc drift · coverage per angle (covered / partial / not investigated). Cite symbols; mark observed / inferred / unverified.

## Rules

- **No code, no doc edits** here. The plan and research live in `.lane/`; nothing lands in the repo tree.
- **Never explore the repo from the parent context** for M research — delegate it. Grep-level existence checks are fine.
- Say "not investigated" rather than speculate. Prefer live runtime paths over similarly named legacy or test-only code.
- No secrets or large code dumps in any artifact.
