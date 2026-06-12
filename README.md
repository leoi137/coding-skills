# coding-skills

Personal Claude Code skills, synced across machines. This repo **is** `~/.claude/skills/` — clone it there directly:

```bash
git clone git@github.com:leoi137/coding-skills.git ~/.claude/skills
# updates on any machine:
cd ~/.claude/skills && git pull
```

## The plan pipeline

Five stages, each operable from a fresh session via artifacts alone:

```
/research-plan → /write-plan → /execute-plan → /review-plan → /document-plan → /commit-push
```

- **research-plan** — isolated Explore subagents produce a cited brief (`research/RESEARCH_<feature>.md`); no code.
- **write-plan** — turns the brief into an ordered, verifiable plan (`plans/TODO_<feature>.md`) with acceptance criteria + Review checkpoints; no code.
- **execute-plan** — implements unit by unit, red-before-green, checkpointing the Changed manifest after every unit; resumable; never commits.
- **review-plan** — 3 adversarial reviewers scoped to the manifest; fixes confirmed defects in place.
- **document-plan** — updates only docs whose recorded invariant changed, per the repo's doc-map.
- **commit-push** — small scoped commits, shared-worktree safe, offers plan-artifact cleanup; the only stage allowed to commit.

[`_shared/pipeline-contract.md`](./_shared/pipeline-contract.md) is the single source of truth for artifact locations, the TODO schema, manifest/finding formats, the model floor, and the universal rules. Every skill reads it on invocation.

## Codex adapters

Codex-native wrappers live under [`codex/skills/`](./codex/skills/). They keep
the same pipeline artifacts and shared contract, but translate Claude-specific
runtime language to Codex. No `AGENTS.md` is included; each target repo owns its
own repo-specific `AGENTS.md`.

Install them globally for Codex with symlinks:

```bash
mkdir -p ~/.agents/skills
for skill in research-plan write-plan execute-plan review-plan document-plan commit-push; do
  ln -sfn ~/.claude/skills/codex/skills/$skill ~/.agents/skills/$skill
done
```

Restart Codex after the first install, then use `/skills` or mention a skill
such as `$research-plan`.
