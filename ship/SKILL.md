---
name: ship
description: Take a verified lane's draft PR to ready for review — catch up with main, gate push, wait for CI to be green (or red only on proven inherited/flaky failures), sweep attribution and PII, write the PR body, mark it ready and move the Linear ticket to review with one comment. Never merges. Use after /verify approves.
---

# ship

**Read `~/.claude/skills/_shared/pipeline-contract.md` first** — CI classes, the commit policy and Linear rules live there. Stage 4. Ready-for-review means "a teammate can merge this now"; a PR is never marked ready while CI is red on something of ours.

## Preconditions

- Inside the lane (`lane here`). `.lane/review.md` verdict is **Approved** or **Approved (fixed)**, and nothing but merges from main landed after its `Reviewed:` sha (`git log --no-merges <sha>..HEAD` is empty) — other new commits need `/verify` again (a one-line fix the review asked for is fine).
- Ticketed repo: bind the plan's ticket if this session hasn't (`ticket show`; bind with no question) — `ticket status` needs it.
- Clean tree: `git status --porcelain` shows nothing tracked.
- `lane set <slug> stage=ship`.

## Steps

1. **Catch up.** `git fetch origin main`. If the branch is behind, `gate push` (background) merges `origin/main` and re-checks everything; green → `git push`. Conflicts → resolve by hand keeping both sides' intent, rerun the gate.
2. **CI.** `ci-watch <pr>` in the background until it finishes. Then:
   - **green** → continue.
   - **ours** → back to `/build`'s CI loop (fix, commit, push, re-watch). Don't continue while anything of ours is red.
   - **inherited / flaky only** → continue only with evidence: the same signature failing on main (`main-health` run link) or a passing rerun. Put that evidence in the PR body.
   - **three red cycles** → stop and report.
   - `ci-watch` exit 3 (timed out with checks still running) → start it once more, then report; exit 4 (couldn't read checks) → look at `gh pr checks <pr>` yourself and report.
3. **Sweep.** Nothing pushed may carry attribution or personal data: `git log origin/main..HEAD -E -i --grep='co-authored-by' --grep='generated with[^[:alnum:]]*\[?claude'` is empty; every author email is a `users.noreply.github.com` address; the diff has no secrets, home paths, hostnames or internal URLs. Anything found → fix before going further (unpushed: amend; pushed: tell the user — a force-push is theirs to decide).
4. **PR body** (`gh pr edit <pr> --body-file …`, no attribution line):
   - first line `Fixes CB-n` (merging closes the ticket; `Part of CB-n` if this is one of several PRs);
   - what changed and why, in 3–6 bullets for a teammate;
   - acceptance criterion → test table;
   - verification: the `gate push` summary from `.lane/gate.json` (steps, duration), CI result, inherited failures with their main-run evidence, and what was **not** verified (e.g. "not checked in a browser").
   Title stays `<subject> (CB-n)`.
5. **Ready.** `gh pr ready <pr>`.
6. **Linear** (ticket skill §4): confirm the PR shows on the ticket; move it to the review status if automation didn't; `ticket status "In Review" --summary "<one plain-English line for the team update>"`; post **one** comment — PR link, what changed, how it was verified, what's left.
7. `lane set <slug> stage=shipped`. Tell the user: PR link, CI state, what's left. The worktree stays until the PR merges; `lane gc` removes it afterwards.

## Rules

- **Never merge** — not even when CI is green and the user is away. Merge, release and post-deploy steps are the team's.
- Never mark ready with ours-red CI; never hide an inherited failure — show its evidence.
- Never force-push without the user's explicit go.
- After ready, new review comments go back through `/build` (fix as commits) and the PR stays ready; the ticket stays In Review.
