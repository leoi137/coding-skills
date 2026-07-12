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
- **write-plan** — turns the brief into an ordered, verifiable plan (`plans/TODO_<feature>.md`) with acceptance criteria; no code.
- **execute-plan** — implements unit by unit, red-before-green, checkpointing the Changed manifest after every unit; resumable; never commits.
- **review-plan** — 3 adversarial reviewers scoped to the manifest; fixes confirmed defects in place.
- **document-plan** — updates only docs whose recorded invariant changed, per the repo's doc-map.
- **commit-push** — small scoped commits, shared-worktree safe, offers plan-artifact cleanup; the only stage allowed to commit.

[`_shared/pipeline-contract.md`](./_shared/pipeline-contract.md) is the single source of truth for artifact locations, the TODO schema, manifest/finding formats, the model floor, and the universal rules. Every skill reads it on invocation.

**Multi-session coordination:** each repo keeps a live session board at `<repo-root>/plans/SESSIONS.md` (never committed) — one section per plan in flight with stage, heartbeat, and claimed files. Every stage reads it on start, registers its own section, and checks its claims against the others before touching shared files; `/commit-push` releases the section when the plan ships. Protocol in the contract's "Session board" section.

## Codex

Codex reads the **same** skills — there is no separate Codex copy. Symlink each
skill into Codex's user skill directory so one `git pull` updates both tools:

```bash
mkdir -p ~/.agents/skills
for skill in research-plan write-plan execute-plan review-plan document-plan commit-push; do
  ln -sfn ~/.claude/skills/$skill ~/.agents/skills/$skill
done
```

Restart Codex after the first install, then use `/skills` or mention a skill
such as `$research-plan`. The skills are mostly tool-agnostic prose; the one
Claude-ism is the Opus/Fable model floor in the shared contract — under Codex,
just use its strongest available model. Repo-specific guidance still belongs in
each target repo's own `AGENTS.md`.
