# Codex adapters

These are Codex-native wrappers for the tracked Claude Code plan-pipeline skills.
They keep the same artifacts and pipeline contract, but translate Claude-only
runtime language to Codex.

No `AGENTS.md` is included here. Repository-specific guidance belongs in each
target repository's own `AGENTS.md`.

## Install

Keep the repo cloned at `~/.claude/skills`, then expose the Codex wrappers from
Codex's user skill directory:

```bash
mkdir -p ~/.agents/skills
for skill in research-plan write-plan execute-plan review-plan document-plan commit-push; do
  ln -sfn ~/.claude/skills/codex/skills/$skill ~/.agents/skills/$skill
done
```

Restart Codex after the first install. Use `/skills` or mention a skill such as
`$research-plan`.
