# Profile: <Product>

Owner decisions and stable pointers only. **Product facts (features, vendors, data, flows) are re-derived from the code on every job** — a profile that records them goes stale exactly the way legal pages do. The "Last audit" section is a list of leads to re-check, not facts.

## Entity
- Legal entity, state of incorporation, principal address, phone (Cal. Civ. Code §1789.3 needs a street address and phone for CA consumers)
- Public brand name, domain, support/legal email
- Where these live in the repo (single source)

## Owner decisions
- Governing law: <state> — why
- Disputes: arbitration yes/no; provider; opt-out window; venue
- Liability cap: <formula>
- Minimum age: <18/16/13>
- Territory: US only / plus <countries>
- Risk appetite notes (e.g., "prefer fewer promises over more features in the policy")

## Repo
- Path(s), legal page files, renderer, last-updated source, company-facts source
- Checks to run; dev server; how changes ship (e.g., merge to main)
- Repo rules that constrain legal edits (shared checkout, branch policy)

## Modules that usually apply
<list, with the code fact that triggers each>

## Canonical product statements
Any compliance-reviewed description the documents must agree with (e.g., an in-app disclosure).

## Last audit (<date>) — leads to re-verify
<findings from the last job, each with file:line>
