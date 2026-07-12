---
name: research-plan
description: Investigate a feature or area of the codebase using isolated Explore subagents. Use before planning or coding when the user asks to understand, map, investigate, or "figure out how X works". Produces a cited research brief; does NOT write code.
---

# research-plan

**Read `~/.claude/skills/_shared/pipeline-contract.md` first** — it defines artifact locations, the brief schema, the model floor, and the universal rules. Stage 1 of the pipeline; the brief is the only thing that flows forward.

Goal: produce an accurate, decision-useful model of a feature **without polluting the parent context** — heavy reading happens in subagents, only compressed findings return here. "Decision-useful," not "complete": you're done once the brief covers entry points, data/control flow, state & persistence, auth/flags/error boundaries, relevant tests, and the open risks. Don't research past that.

> **Model floor:** every `Agent` call runs Opus or Fable — never below Opus-class — and the model is passed explicitly on every call. Full policy in the contract; fail closed if no frontier model is available.

## How to run

1. **Restate the target** in one sentence with explicit scope. If vague, ask one clarifying question or proceed on a stated interpretation — never guess silently. Record the branch/commit so citations are tied to a snapshot. Register `<feature>` on the session board (contract §Session board) with `Stage: research` — no file claims yet, this stage is read-only, but other sessions see the pipeline is in flight.

2. **Scout first if the territory is unknown.** When entry points and structure aren't already clear, spawn ONE cheap scout subagent to map the directory tree, top-level modules, key symbols, and dead/generated/vendored zones to exclude (stale plan files in `plans/`/`research/` are context, not current truth — don't treat them as live state). Decompose against its map, not a guess. If you already know the entry points, skip to step 3.

3. **Decompose into independently answerable angles** — the fewest that cover the checklist, not a target count. Typical: UI/entry points · backend/API/control flow · data models & persistence · auth/flags/telemetry/errors · tests. For any non-trivial target, **always add a cross-cutting/integration angle** — seam bugs live in the handoffs between cleanly-sliced angles. Minimize *redundant* overlap; assign explicit ownership + exclusions.

4. **Spawn `Explore` subagents in parallel** — one tool-use block, multiple `Agent` calls, each on the frontier model. Each prompt is self-contained (the subagent sees none of this conversation): feature + why · this angle, in/out of scope · known start paths/symbols · the snapshot · thoroughness (`medium` default, `very thorough` for large unknown areas) · **if the project keeps distilled docs (a `docs/` reference tree, a CLAUDE.md doc-map), read the relevant one FIRST as a starting map, then verify against code — don't re-derive what a doc already records** · **"distinguish what you observed in code from what you inferred."** Output: **under 400 words (up to 600 for a multi-service angle), structured as — Summary (2 sentences) → Key evidence (symbol in path — significance) → Data/control flow (numbered) → Observed vs inferred → Doc drift → Gotchas → Open questions.**

5. **Reconcile, then synthesize.** Collect results. **Surface contradictions** between angles rather than picking one or averaging — disagreements are where the bugs and misunderstandings live. Make empty/errored angles explicit; don't let a failed subagent silently vanish. If a load-bearing claim is disputed, spawn ONE focused follow-up or verification subagent — at most one extra wave. Then write the brief per the contract's **research brief schema**, including the **Key-file map** appendix (`path — one-line role`) so `/write-plan` and `/execute-plan` never re-scout this territory.

6. **Right-size the downstream plan.** If the target is too large for one plan — multiple independent subsystems, or phases that don't share a deliverable — say so in **Next step** and propose the split into separate pipelines (one RESEARCH brief can feed several `TODO_*.md` plans). A too-big plan fails in execute; this is the cheapest place to cut it.

7. **Save** to `<repo-root>/research/RESEARCH_<feature>.md` (the contract's canonical home; create the dir). Don't overwrite a different brief silently — update only if it's the same target, else use a new name. Keep under ~300 lines; cut repetition before evidence.

## Rules

- **Never explore the repo from the parent context.** Verification is a *delegated* job — spawn a subagent, don't start reading files yourself. ("Just one peek" erodes the isolation this whole mode exists for.)
- **Don't write code — or edit docs.** Research produces a brief, nothing else. Capture doc drift as a finding; `/document-plan` closes it after the change is confirmed correct (research is mixed-confidence and must not write inference into evergreen reference docs).
- **Cite symbols, not just lines** — `handleFoo in bar.dart`. Line numbers drift and get hallucinated; symbols survive edits.
- **Mark confidence** — observed / inferred / conflicting / unverified. Never present inference as fact.
- **Say "not investigated"** rather than speculate. Prefer active runtime paths over similarly-named legacy or test-only code.
- **No secrets** or large code dumps in the brief.
- **One subagent is fine** if one investigation answers it. Prefer a focused follow-up over a speculative conclusion.
