---
name: document-plan
description: Update project documentation to match the changes a plan made — scoped to that plan's manifest, following the repo's own doc-map. Updates only docs whose recorded invariant actually changed; closes flagged drift; never commits. Use after /review-plan approves.
---

# document-plan

**Read `~/.claude/skills/_shared/pipeline-contract.md` first** — it defines the manifest format, artifact lifecycle, model floor, and universal rules. Final stage of the pipeline. This is the deliberate moment to *write* to docs: earlier stages only read docs and flag drift; this stage fixes it, once the change is confirmed correct.

Goal: keep the docs true to the code by updating **only the documentation the just-shipped change actually affects** — no drift, no bloat, no sidetracking.

> **Model floor:** every `Agent` call runs Opus or Fable — never below Opus-class — passed explicitly. Full policy in the contract; fail closed if no frontier model is available.

## Preconditions

- A `plans/TODO_<feature>.md` whose `## Review` verdict is **Approved** or **Approved (fixed)**. Don't document a `Changes required` or `Blocked` change — you'd be recording something about to change.
- Read the plan's **`## Changed manifest`** (files + symbols), `## Result`, and `## Review`. That manifest is your scope. Everything you need is in the artifacts — this stage runs identically in a fresh session.
- Read the matching `research/RESEARCH_<feature>.md` if present — its **Doc drift** section is a ready-made to-do list this stage closes out.
- Set this plan's session-board entry to `Stage: document` and add the doc files you'll touch to its claims (contract §Session board) — doc files collide across sessions just like code.

## Find what to document — follow the repo's doc-map, don't invent one

1. **Locate the project's doc convention.** Most repos encode it: a `CLAUDE.md`/`AGENTS.md` with a *"when you change X, update Y"* table, a `docs/` reference tree, per-module READMEs that act as contracts, schema tables. Read the nearest one. If the project has no doc convention, there's nothing to maintain — report that and stop.
2. **Map the Changed manifest onto that table.** For each changed file/symbol, the doc-map says which doc (if any) records an invariant about it. Add the **Doc drift** items the research brief flagged.

## Update discipline — only when an invariant changed

The repo's own rule, and the anti-bloat guardrail: **update a reference doc only when you changed an invariant it records.** A new feature, a renamed function, a refactored hook → usually *no* doc edit. A changed contract, a new RLS/auth rule, a new state-machine constraint, an expanded frozen vocabulary, a new action surface, a schema/column change → *yes*.

Respect the project's stated doc-authority and immutability rules — read them, don't assume (e.g. "the per-function README is the contract; update it with every action-surface change"; "this vocabulary is frozen — never touch it"). When the project marks something immutable, don't edit it — flag the conflict instead.

## Do the updates

For each in-scope doc:
- **Verify against live code first** (verify-at-use) — document what the code now *does*, not what you assume. Reference docs are high-confidence; never write inference into them.
- Edit it: reference invariants, contract READMEs, schema tables, and the CLAUDE.md doc-map inventory (new route/page/function) — whatever the doc-map dictates.
- **Document the contract, never the implementation.** For a symbol/function, record what it *guarantees* — purpose, params/returns, invariants, edge cases, and the *why* — not a line-by-line restatement of its body. The body rots instantly and grep already shows it; the contract is what code can't say about itself. Cite by symbol name, not raw line numbers. Keep one consistent shape so every reference reads the same.
- **Fix drift you're already touching:** if an in-scope doc describes something the code no longer does, correct it (code wins). Drift *outside* this plan's area → report it, don't chase it. Chasing it is the sidetrack.

### One fact, one home — single source of truth

Each invariant lives in exactly **one** canonical doc; everywhere else *links* to it. Duplication is the root cause of drift, so kill it at the source:
- Before writing a fact, check it isn't already documented elsewhere. If it is, edit the canonical copy and link from here — don't restate it.
- If the change touches a fact you find **duplicated** across docs, consolidate it into the one canonical home and replace the other copies with links. (Consolidating duplicates the change already exposed is in scope — hunting unrelated duplication is not.)

### Keep the docs navigable

Docs a CTO can't *find* don't exist. Whenever this change adds, moves, or renames a doc:
- Update the repo's **doc index / entry-point** (the doc-map table, `docs/README.md`, nav list — whatever the repo uses) so nothing becomes an orphan.
- Maintain **bidirectional cross-links** between related docs, so a reader lands anywhere and can reach the rest.
- Use **stable, descriptive headings** as anchors — deep-links break when headings churn, so rename a heading only when the concept itself changed.

### Searchable terminology

Use the repo's **one canonical term per concept** — never coin a synonym for something already named — and put that keyword in the heading, so the doc is greppable. If the repo keeps a glossary, it's the term authority: add a genuinely new concept there; otherwise match the term already in use.

## Report

- Append a `## Docs` section to the TODO: each doc updated + the one-line reason (which invariant changed), any duplication consolidated, any index/cross-link change, and each **Doc drift** item closed. If nothing warranted a change, say so plainly — "no invariant changed; no doc edits" is a correct outcome.
- Set the TODO's `Status: Done`.
- One-line completion to the user, noting the pipeline is done and that `/commit-push` will offer to delete the plan's TODO + RESEARCH artifacts when the work ships (the contract's lifecycle rule — git history is the archive).

## Rules

- **Stay in scope:** the Changed manifest + flagged drift. Don't document or "improve" unrelated docs.
- **No commits, stashes, or pushes** — doc edits land in the working tree for the user to read.
- **Don't over-document.** No edit beats a redundant one. Docs record what code *can't* say itself — invariants, contracts, the "why."
- **One fact, one home.** Never document the same invariant in two places — link to the canonical copy. Document the contract, not the implementation.
- **Leave the docs navigable.** No orphans: a new/moved/renamed doc must be reachable from the index and cross-linked. Use the repo's canonical term, consistently.
- **Don't touch code** — this stage edits docs only. A mismatch where the *code* is wrong is a `/review-plan` finding, not a doc edit.
- **Don't invent coverage** — if you couldn't confirm a doc claim against code, say so rather than guessing.
- **Respect immutability** — never edit a doc or vocabulary the project marks frozen; flag the conflict.
