# coding-skills

Personal Claude Code skills, synced across machines. This repo **is** `~/.claude/skills/` — clone it there directly:

```bash
git clone git@github.com:leoi137/coding-skills.git ~/.claude/skills
# updates on any machine:
cd ~/.claude/skills && git pull
```

## The pipeline

Four stages, each operable from a fresh session via the lane's artifacts alone:

```
/scope → /build → /verify → /ship
```

- **scope** — resolves the ticket, creates the **lane** (its own worktree + branch from fresh `origin/main`), sizes the work S/M/L (L gets split), researches as much as the size needs, and writes an approvable `.lane/PLAN.md`: acceptance criteria, one-commit units, docs impact, what CI will run. Research-only mode answers "how does X work" with no lane.
- **build** — per unit: ground, red test, code, `gate unit`, commit `… (CB-n)`. `gate push` before every push; the first push opens a draft PR; `ci-watch` keeps CI green in the background.
- **verify** — top-level session only, in parallel with CI: one or two reviewers on the session's model see the plan, diff, gate and CI results — never the implementer's transcript — and confirmed defects are fixed as commits.
- **ship** — catch up with main, CI green (or red only on proven inherited/flaky failures), attribution/PII sweep, PR body, mark ready, Linear to review. Never merges.
- **commit-push** — ad-hoc commits outside a lane: this chat's edits only, grouped by the revert test, one approval, never co-authored.

The plan's approval is the gate: once approved, `/build` commits each unit, pushes and opens a draft PR without asking again. Only `/ship` marks the PR ready, and nothing in the pipeline merges.

[`_shared/pipeline-contract.md`](./_shared/pipeline-contract.md) is the single source of truth for lanes, the compute budget, the gates, the commit policy, CI classes, the PLAN.md schema and the finding format. Every stage reads it on invocation.

## Toolkit and hooks: `_bin/`

Deterministic scripts the stages call — `lane`, `heavy`, `gate`, `ci-sigs`, `main-health`, `ci-watch` — and three hooks: `heavy-guard` (queues RAM-heavy commands machine-wide), `commit-guard` (blocks AI attribution) and `agent-guard` (subagents run on the session's model). Usage, install snippet and the verified Claude Code mechanics: [`_bin/README.md`](./_bin/README.md).

## Linear tickets: `/ticket`

In a repo that has `.claude/linear.json`, every change belongs to a Linear ticket. The `ticket` skill finds or creates the ticket and asks you once per piece of work. It moves the ticket In Progress on the first edit, In Review when the PR is marked ready and Done on merge, and it puts the ID where Linear's GitHub integration links it. Three hooks back it up:

- **gate:** no edit without a ticket bound to the session, and no commit or PR without the ID
- **prompt context:** the bound ticket is shown each turn, so drift gets noticed
- **status line:** shows the bound ticket

`/scope` resolves and binds the ticket for a lane. The hooks and status line are installed once per machine in `~/.claude/settings.json`: see [`ticket/references/setup.md`](./ticket/references/setup.md).

## Codex

Codex reads the **same** skills — there is no separate Codex copy. Symlink each
skill into Codex's user skill directory so one `git pull` updates both tools:

```bash
mkdir -p ~/.agents/skills
for skill in scope build verify ship commit-push; do
  ln -sfn ~/.claude/skills/$skill ~/.agents/skills/$skill
done
# remove links to the retired stage names
for old in research-plan write-plan execute-plan review-plan document-plan; do
  rm -f ~/.agents/skills/$old
done
```

Restart Codex after the first install, then use `/skills` or mention a skill
such as `$scope`. The skills are mostly tool-agnostic prose. Codex has no hooks,
so the `_bin` scripts enforce their own rules (slots, sweeps) and the hooks are a
Claude Code backstop. Repo-specific guidance still belongs in each target repo's
own `AGENTS.md`.
